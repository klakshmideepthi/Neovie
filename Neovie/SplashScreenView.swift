import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color(hex: 0xE7ECEE).edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("Icon4")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Neovie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                ProgressView()
                    .padding(.top, 50)
            }
        }
    }
}
