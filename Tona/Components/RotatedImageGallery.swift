import SwiftUI

struct RotatedImageGallery: View {
    let images: [UIImage]
    var body: some View {
        ZStack {
            ForEach(images.indices, id: \.self) { idx in
                Image(uiImage: images[idx])
                    .resizable()
                    .aspectRatio(3/4, contentMode: .fill)
                    .frame(width: 180, height: 240)
                    .clipped()
                    .cornerRadius(18)
                    .shadow(radius: 6, y: 2)
                    .rotationEffect(.degrees(rotation(for: idx, count: images.count)))
                    .offset(x: offset(for: idx, count: images.count), y: 0)
            }
        }
        .frame(height: 260)
    }
    private func rotation(for idx: Int, count: Int) -> Double {
        // Spread rotation between -12 and +12 degrees
        guard count > 1 else { return 0 }
        let spread = 24.0
        let step = count == 1 ? 0 : spread / Double(count - 1)
        return -spread/2 + Double(idx) * step
    }
    private func offset(for idx: Int, count: Int) -> CGFloat {
        // Spread horizontally for overlap
        guard count > 1 else { return 0 }
        let totalWidth: CGFloat = 60
        let step = count == 1 ? 0 : totalWidth / CGFloat(count - 1)
        return -totalWidth/2 + CGFloat(idx) * step
    }
} 