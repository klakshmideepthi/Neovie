import SwiftUI

struct MainView: View {
    @State private var isActive = false
    @StateObject private var signInManager = GoogleSignInManager.shared
    
    var body: some View {
        Group {
            if isActive {
                ContentView()
            } else {
                SplashScreenView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}
