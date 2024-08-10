import SwiftUI

struct CustomNavigationBar: View {
    let title: String
    let showSettingsButton: Bool
    let settingsAction: () -> Void
    
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: 0x313131))
                .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                if showSettingsButton {
                    Button(action: settingsAction) {
                        Image(systemName: "person")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(hex: 0x313131))
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: 0xEDEDED))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}
