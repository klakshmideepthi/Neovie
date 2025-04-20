import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let showSettingsButton: Bool
    let settingsAction: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24))
                .foregroundColor(AppColors.textColor)
                .frame(maxWidth: .infinity)
            Spacer()
            if showSettingsButton {
                Button(action: settingsAction) {
                    Image(systemName: "person")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textColor)
                }
            }
        }
        .padding()
        .background(
            Color.clear
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.top)
        )
    }
}
