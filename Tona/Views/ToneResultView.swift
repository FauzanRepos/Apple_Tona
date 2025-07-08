import SwiftUI

struct ToneResultView: View {
    @Binding var toneName: String
    let previewImage: UIImage
    let onApply: () -> Void
    let onSave: (() -> Void)?
    let onBack: (() -> Void)?
    
    @State private var isEditingName = false
    @FocusState private var nameFieldFocused: Bool
    
    init(toneName: Binding<String>, previewImage: UIImage, onApply: @escaping () -> Void, onSave: (() -> Void)? = nil, onBack: (() -> Void)? = nil) {
        self._toneName = toneName
        self.previewImage = previewImage
        self.onApply = onApply
        self.onSave = onSave
        self.onBack = onBack
    }
    
    var body: some View {
        ZStack {
            // Blurred/opacity background image
            if let blurred = previewImage.applyBlur(radius: 16) {
                Image(uiImage: blurred)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.18)
                    .ignoresSafeArea()
            } else {
                Color.tonaOffWhite.ignoresSafeArea()
            }
            VStack(spacing: 0) {
                // Navigation bar
                HStack {
                    Button(action: { onBack?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Collection")
                        }
                        .foregroundColor(Color.tonaAccentBlue)
                        .font(.system(size: 17, weight: .medium))
                    }
                    Spacer()
                    Button(action: { onSave?() }) {
                        Text("Save")
                            .foregroundColor(Color.tonaAccentBlue)
                            .font(.system(size: 17, weight: .medium))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 4)
                // Title (faded, like nav bar title)
                HStack {
                    Text("Tone result")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.tonaDeepBlue.opacity(0.22))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                Spacer(minLength: 0)
                // Main content
                VStack(spacing: 18) {
                    Text("This is your tone!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.tonaDeepBlue)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    Image(uiImage: previewImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 260, height: 260)
                        .cornerRadius(22)
                        .shadow(color: Color.tonaCardShadow, radius: 12, y: 6)
                        .padding(.bottom, 8)
                    // Tone name with edit icon
                    HStack(spacing: 8) {
                        if isEditingName {
                            TextField("Tone name", text: $toneName)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.tonaDeepBlue)
                                .multilineTextAlignment(.center)
                                .focused($nameFieldFocused)
                                .onAppear { nameFieldFocused = true }
                                .onSubmit { isEditingName = false }
                                .frame(minWidth: 80, maxWidth: 180)
                                .padding(.vertical, 4)
                                .background(Color.tonaOffWhite)
                                .cornerRadius(8)
                        } else {
                            Text(toneName.isEmpty ? "Untitled" : toneName)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.tonaDeepBlue)
                            Button(action: { isEditingName = true }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.tonaAccentBlue)
                            }
                            .accessibilityLabel("Edit tone name")
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                // Apply button at the bottom
                Button(action: onApply) {
                    Text("Apply to my photos")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            Color.tonaDeepBlue.opacity(0.08)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        )
                        .foregroundColor(Color.tonaDeepBlue)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - UIImage Blur Helper
extension UIImage {
    func applyBlur(radius: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = filter?.outputImage else { return nil }
        let context = CIContext()
        if let cgimg = context.createCGImage(output, from: ciImage.extent) {
            return UIImage(cgImage: cgimg)
        }
        return nil
    }
} 