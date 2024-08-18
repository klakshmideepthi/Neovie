import SwiftUI

struct AppColors {
    static let backgroundColor = Color("BackgroundColor")
    static let textColor = Color("TextColor")
    static let accentColor = Color("AccentColor")
    static let secondaryBackgroundColor = Color("SecondaryBackgroundColor")
    static let buttonBackground = Color("ButtonBackground")
}


extension Color {
    static let customTextColor = Color("TextColor")
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
