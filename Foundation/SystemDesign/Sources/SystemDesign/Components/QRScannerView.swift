import AVFoundation
import SwiftUI

// Live camera QR scanner. AVFoundation only - no third-party dependency.
public struct QRScannerView: UIViewControllerRepresentable {
    // Side length of the centered square that is scanned; the on-screen frame must use the same value.
    public static let scanAreaSize: CGFloat = 260

    private let isFailed: Bool
    private let onScan: (String) -> Void

    // isFailed: true while the caller shows a scan error; going back to false re-arms the scanner.
    public init(isFailed: Bool = false, onScan: @escaping (String) -> Void) {
        self.isFailed = isFailed
        self.onScan = onScan
    }

    public func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onScan = onScan
        return controller
    }

    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.isFailed = isFailed
    }

    // @preconcurrency: this delegate is only ever called on .main (set below), so the
    // actor-isolation crossing Swift 6 flags here is a false positive.
    public final class ScannerViewController: UIViewController, @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
        var onScan: ((String) -> Void)?
        private let session = AVCaptureSession()
        private let output = AVCaptureMetadataOutput()
        private let preview = AVCaptureVideoPreviewLayer()
        // Debounced so one code in frame doesn't fire onScan on every video frame.
        private var hasScanned = false
        // After an error is dismissed, allow the same code to be scanned again.
        var isFailed = false {
            didSet {
                if oldValue && !isFailed {
                    hasScanned = false
                }
            }
        }

        public override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .black
            configureSession()
        }

        public override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            hasScanned = false
            if !session.isRunning {
                DispatchQueue.global(qos: .userInitiated).async { [session] in
                    session.startRunning()
                }
            }
        }

        public override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if session.isRunning {
                session.stopRunning()
            }
        }

        private func configureSession() {
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input)
            else {
                return
            }
            session.addInput(input)

            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr]

            preview.session = session
            preview.videoGravity = .resizeAspectFill
            preview.frame = view.bounds
            view.layer.addSublayer(preview)
        }

        public override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            preview.frame = view.bounds
        }

        // The centered square, in the same coordinates as the preview layer
        private var scanSquare: CGRect {
            let side = QRScannerView.scanAreaSize
            return CGRect(
                x: (view.bounds.width - side) / 2,
                y: (view.bounds.height - side) / 2,
                width: side,
                height: side
            )
        }

        public func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard !hasScanned else { return }

            for metadataObject in metadataObjects {
                // Convert the code's position from camera space to on-screen points
                guard let code = preview.transformedMetadataObject(for: metadataObject)
                        as? AVMetadataMachineReadableCodeObject,
                      let payload = code.stringValue
                else {
                    continue
                }

                // Ignore codes whose center is outside the square
                let center = CGPoint(x: code.bounds.midX, y: code.bounds.midY)
                guard scanSquare.contains(center) else { continue }

                hasScanned = true
                onScan?(payload)
                return
            }
        }
    }
}
