import Foundation
import GoogleSignIn
import Firebase
import GoogleSignInSwift

class GoogleSignInManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userProfile: GIDProfileData?
    
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
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.isSignedIn = false
            self.userProfile = nil
            print("User signed out successfully")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
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
                self?.userProfile = user.profile
            } else {
                print("Firebase Authentication successful, but no user returned")
            }
            
            print("User signed in successfully")
        }
    }
}
