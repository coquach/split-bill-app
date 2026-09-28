import CoreImage.CIFilterBuiltins
import SwiftUI

/// The card on Split QR: an optional title/subtitle header, the code itself
/// with the SplitPay badge centred on it, and an optional caption row below
/// a hairline.
///
/// Previously this was just "a card containing a QR code"; the Split QR
/// screen needs all three parts, and building them at the call site would
/// have meant a second, near-identical card living in the feature module.
public struct QRCard: View {
    private let data: String
    private let title: String?
    private let subtitle: String?
    private let captionLabel: String?
    private let captionValue: String?

    public init(
        data: String,
        title: String? = nil,
        subtitle: String? = nil,
        captionLabel: String? = nil,
        captionValue: String? = nil
    ) {
        self.data = data
        self.title = title
        self.subtitle = subtitle
        self.captionLabel = captionLabel
        self.captionValue = captionValue
    }

    public var body: some View {
        VStack(spacing: AppSpacing.md) {
            if title != nil || subtitle != nil {
                VStack(spacing: AppSpacing.xxs) {
                    if let title {
                        Text(title)
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(AppTypography.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }

            codeWithBadge

            if let captionLabel, let captionValue {
                Rectangle()
                    .fill(Color.appBorderDefault)
                    .frame(height: 1)

                // One line, two weights: the label stays quiet so the amount
                // is what the eye lands on.
                HStack(spacing: AppSpacing.xxs) {
                    Text(captionLabel)
                        .font(AppTypography.body)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(captionValue)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.appSurfacePrimary)
        .clipShape(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
        )
    }

    // MARK: - Code

    private var codeWithBadge: some View {
        Group {
            if let qrImage = Self.makeQRCode(from: data) {
                Image(uiImage: qrImage)
                    .interpolation(.none) // keeps QR edges crisp when scaled up
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .fill(Color.appSurfaceSecondary)
                    .overlay {
                        Text("Unable to generate QR code")
                            .font(AppTypography.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 240)
        .overlay { brandBadge }
    }

    /// Purely decorative — no tap target. The white ring is what keeps the
    /// badge visually separate from the modules underneath it.
    ///
    /// Uses `appPrimary` rather than the icon's own brand blue: the system
    /// has one accent, and a second one introduced for a single badge would
    /// be a palette fork for no functional gain.
    private var brandBadge: some View {
        Circle()
            .fill(Color.appPrimary)
            .frame(width: 44, height: 44)
            .overlay {
                Text("S")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .overlay {
                Circle().strokeBorder(.white, lineWidth: 4)
            }
    }

    // MARK: - Generation

    // Core Image's built-in generator — part of the iOS SDK, no third-party
    // library needed.
    private static func makeQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        // "H" = ~30% of the code can be obscured and still scan. That is what
        // makes the centre badge safe: at the default "M" level the overlay
        // would eat past the recoverable margin and some scanners would fail.
        filter.correctionLevel = "H"

        guard let outputImage = filter.outputImage else { return nil }

        // The raw QR image is a few pixels per module, so scale it up before
        // converting or it'll look blurry.
        let transformed = outputImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )

        guard
            let cgImage = context.createCGImage(
                transformed,
                from: transformed.extent
            )
        else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// Exposed so a screen can hand the same rendered code to a share sheet
    /// without regenerating it with different settings.
    public static func renderedImage(for data: String) -> UIImage? {
        makeQRCode(from: data)
    }
}
