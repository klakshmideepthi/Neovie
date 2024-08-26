import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let showSettingsButton: Bool
    let settingsAction: () -> Void
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 24))
                .foregroundColor(AppColors.textColor)
                .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                if showSettingsButton {
                    Button(action: settingsAction) {
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.textColor)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.backgroundColor)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}
