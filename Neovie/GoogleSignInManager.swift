import Foundation
import GoogleSignIn
import Firebase
import GoogleSignInSwift
import SwiftUI

class GoogleSignInManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var googleProfile: GIDProfileData?
    @Published var userProfile: UserProfile?
    
    static let shared = GoogleSignInManager()
    
    private init() {
        checkSignInStatus()
    }
    
    func checkSignInStatus() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                guard error == nil else {
                    print("Error restoring previous sign-in: \(error!.localizedDescription)")
                    return
                }
                self?.handleSignInResult(user: user)
            }
        } else {
            self.isSignedIn = false
            self.googleProfile = nil
            self.userProfile = nil
        }
    }
    
    func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No client ID found, unable to continue with sign in")
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("There is no root view controller!")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let result = result else {
                print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self?.handleSignInResult(user: result.user)
        }
    }
    
    func signOut() {
        resetChatbotWelcomeStatus { [weak self] in
            guard let self = self else { return }
            
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                self.isSignedIn = false
                self.googleProfile = nil
                self.userProfile = nil
                print("User signed out successfully")
                NotificationCenter.default.post(name: .userDidSignOut, object: nil)
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError)")
            }
        }
    }
    
    private func resetChatbotWelcomeStatus(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found, unable to reset chatbot welcome status")
            completion()
            return
        }

        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(var profile):
                profile.hasSeenChatbotWelcome = false
                FirestoreManager.shared.saveUserProfile(profile) { saveResult in
                    switch saveResult {
                    case .success:
                        print("User profile updated to before seeing ChatbotWelcomeView")
                    case .failure(let error):
                        print("Error updating user profile: \(error.localizedDescription)")
                    }
                    completion()
                }
            case .failure(let error):
                print("Error fetching user profile: \(error.localizedDescription)")
                completion()
            }
        }
    }
    
    private func handleSignInResult(user: GIDGoogleUser?) {
        guard let user = user else {
            print("Error: No user found")
            return
        }
        
        guard let idToken = user.idToken?.tokenString else {
            print("Error: Unable to fetch ID token")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            if let error = error {
                print("Firebase sign-in error: \(error.localizedDescription)")
                return
            }
            
            if let firebaseUser = authResult?.user {
                print("Firebase Authentication successful. UID: \(firebaseUser.uid)")
                self?.isSignedIn = true
                self?.googleProfile = user.profile
            } else {
                print("Firebase Authentication successful, but no user returned")
            }
            
            print("User signed in successfully")
        }
    }
}

extension Notification.Name {
    static let userDidSignOut = Notification.Name("userDidSignOut")
}
