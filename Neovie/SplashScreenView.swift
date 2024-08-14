import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("Icon4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.5, 200), height: min(geometry.size.width * 0.5, 200))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("Neovie")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textColor)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                        .padding()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentColor))
                        .scaleEffect(1.5)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
