import SwiftUI

struct OnboardingView: View {
    @State var progressState = ProgressState()
    @State private var userProfile = UserProfile()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                    VStack(spacing: 60) {
                        if let uiImage = UIImage(named: "Icon4") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        } else {
                            Text("Image not found")
                                .foregroundColor(.red)
                        }
                        
                        Text("Welcome to Neovie")
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding()
                            .fontWeight(.bold)
                        
                        Text("Your personalized weight loss journey")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: UserInfo1(userProfile: $userProfile, progressState: $progressState).navigationBarBackButtonHidden(true)) {
                            Text("Great!")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

