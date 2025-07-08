import SwiftUI

struct AdjustmentSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(value, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $value, in: range, step: 0.01)
                .accentColor(.blue)
        }
    }
} 