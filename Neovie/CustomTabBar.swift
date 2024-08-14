import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            tabButton(image: selectedTab == 0 ? "home1" : "home2", tag: 0)
            Spacer()
            tabButton(image: selectedTab == 1 ? "log1" : "log2", tag: 1)
            Spacer()
            tabButton(image: selectedTab == 2 ? "chat1" : "chat2", tag: 2)
        }
        .padding(.horizontal, 60)
        .padding(.bottom, 30)
        .padding(.top, 20)
        .background(AppColors.secondaryBackgroundColor)
    }
    
    private func tabButton(image: String, tag: Int) -> some View {
        Button(action: {
            selectedTab = tag
        }) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        }
    }
}
