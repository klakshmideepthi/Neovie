import SwiftUI
import Lottie

struct ChatbotWelcomeView: View {
    var onCompletion: () -> Void
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                    VStack(spacing: 30) {
                        let dimension = min(geometry.size.width, geometry.size.height) * 0.55
                        LottieView(name: "ChatAI",play: true)
                            .frame(width: dimension, height: dimension)
                        
                        Text("Trusty helper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textColor)
                        
                        Text("Hi, I'm intelligent Helpyy and I will help you manage your healthcare")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .foregroundColor(AppColors.textColor)
                        
                        Spacer()
                        
                        NavigationLink(destination: ChatbotHomeView().navigationBarBackButtonHidden(true)) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(AppColors.accentColor)
                                .cornerRadius(10)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            onCompletion()
                        })
                        .padding(.horizontal)
                        
                        Spacer().frame(height: geometry.size.height * 0.01)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
