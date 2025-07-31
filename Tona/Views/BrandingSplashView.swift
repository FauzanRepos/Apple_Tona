import SwiftUI

struct BrandingSplashView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Color.tonaOffWhite.edgesIgnoringSafeArea(.all)
            VStack {
                Image("BrandLogo") // Assuming there's a logo asset named "BrandLogo"
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                Text("Welcome to Tona")
                    .font(TonaTheme.font(size: 28, weight: .bold))
                    .foregroundColor(TonaTheme.primaryColor)

                Spacer()

                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(TonaTheme.font(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(TonaTheme.primaryColor)
                        .cornerRadius(8)
                }
                .padding(.bottom, TonaTheme.paddingLarge)
            }
        }
        .transition(.opacity) // Fade animation
    }
}
