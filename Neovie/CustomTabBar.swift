import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var animationStates: [Bool] = [false, false, false, false]
    @Binding var showingNewLog: Bool
    @ObservedObject var viewModel: HomePageViewModel
    
    var body: some View {
        HStack {
            tabButton(image: selectedTab == 0 ? "home1" : "home2", tag: 0)
            Spacer()
            tabButton(image: selectedTab == 1 ? "log1" : "log2", tag: 1)
            Spacer()
            if selectedTab == 0 {
                newLogButton
                Spacer()
            }
            tabButton(image: selectedTab == 2 ? "explore1" : "explore2", tag: 2)
            Spacer()
            tabButton(image: selectedTab == 3 ? "chat1" : "chat2", tag: 3)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 30)
        .padding(.top, 20)
        .background(AppColors.secondaryBackgroundColor)
    }
    
    private func tabButton(image: String, tag: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedTab = tag
                animationStates[tag].toggle()
            }
            
            // Reset the animation state after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animationStates[tag] = false
            }
        }) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .scaleEffect(animationStates[tag] ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animationStates[tag])
        }
    }
    
    private var newLogButton: some View {
        Button(action: {
            showingNewLog = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 16,weight: .bold))
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .background(AppColors.accentColor)
                .cornerRadius(15)
                .shadow(radius: 3)
        }
    }
}
