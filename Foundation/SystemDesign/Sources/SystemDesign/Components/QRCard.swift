import SwiftUI
import CoreImage.CIFilterBuiltins

/// A card showing a generated QR code with an optional caption — used
/// on the Split QR screen.
public struct QRCard: View {
    private let data: String
    private let caption: String?

    public init(data: String, caption: String? = nil) {
        self.data = data
        self.caption = caption
    }

    public var body: some View {
        VStack(spacing: AppSpacing.sm) {
            if let qrImage = generateQRCode(from: data) {
                Image(uiImage: qrImage)
                    .interpolation(.none) // keeps QR edges crisp when scaled up
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
            } else {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.appSurface)
                    .frame(width: 220, height: 220)
                    .overlay {
                        Text("Unable to generate QR code")
                            .font(AppTypography.caption)
                            .foregroundStyle(Color.appOnSurface.opacity(0.6))
                    }
            }

            if let caption {
                Text(caption)
                    .font(AppTypography.caption)
                    .foregroundStyle(Color.appOnSurface.opacity(0.6))
            }
        }
        .padding(AppSpacing.lg)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
    }

    // Uses Core Image's built-in QR generator — part of the iOS SDK,
    // no third-party library needed.
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        guard let outputImage = filter.outputImage else { return nil }

        // The raw QR image is tiny (a few pixels per square), so scale
        // it up before converting to a UIImage or it'll look blurry.
        let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = context.createCGImage(transformed, from: transformed.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
