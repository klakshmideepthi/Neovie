import SwiftUI

struct ChatbotWelcomeView: View {
    @State private var navigateToMainView = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    // Decorative circles
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .position(x: 50, y: 50)
                    
                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width - 50, y: geometry.size.height - 50)
                    
                    // Main content
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Text("Trusty helper")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Hi, I'm intelligent Helpyy and I will help you manage your healthcare")
                            .font(.title3)
                            .multilineTextAlignment(.center)
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
                                .background(Color(hex: 0x708E99))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 50) // Add some bottom padding
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToMainView) {
                ChatbotHomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

