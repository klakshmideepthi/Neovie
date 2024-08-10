import SwiftUI
import Lottie

struct ChatbotWelcomeView: View {
    @State private var navigateToMainView = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    
                    // Main content
                    VStack(spacing: 30) {
                        let dimension = min(geometry.size.width, geometry.size.height) * 0.55
                            LottieView(name: "ChatAI")
                                .frame(width: dimension, height: dimension)
                        
                        Text("Trusty helper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Hi, I'm intelligent Helpyy and I will help you manage your healthcare")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                        
                        Spacer()
                        Button(action: {
                            navigateToMainView = true
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: 0xC67C4E))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)// Add some bottom padding
                    }
                    .padding()
                }
                .background(Color(hex: 0xEDEDED))
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(destination: ChatbotHomeView().navigationBarBackButtonHidden(true),
                               isActive: $navigateToMainView) {
                    EmptyView()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
