import SwiftUI

struct ShareButton: View {
    let image: UIImage
    @State private var showShareSheet = false
    var body: some View {
        Button("Share") {
            showShareSheet = true
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.purple.opacity(0.8))
        .foregroundColor(.white)
        .cornerRadius(10)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [image])
        }
    }
} 