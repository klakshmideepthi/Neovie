import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var navigateToSignedOutView = false

    let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            image: "onboarding1", 
            title: "Your GLP-1 Journey Companion", 
            description: "Track medications, manage side effects, and get personalized support for your weight loss journey.", 
            buttonText: "Know more"
        ),
        OnboardingPage(
            image: "onboarding2", 
            title: "Holistic Progress Tracking", 
            description: "Monitor more than just weight - track water intake, protein goals, side effects, and celebrate non-scale victories.", 
            buttonText: "Know more"
        ),
        OnboardingPage(
            image: "onboarding3", 
            title: "Evidence-Based Support", 
            description: "Access reliable information, medication reminders, and expert guidance for sustainable results.", 
            buttonText: "Let's start"
        )
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        HStack {
                            ForEach(0..<onboardingPages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? AppColors.accentColor : Color.gray.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        TabView(selection: $currentPage) {
                            ForEach(0..<onboardingPages.count, id: \.self) { index in
                                OnboardingPageView(page: onboardingPages[index], isLastPage: index == onboardingPages.count - 1, action: {
                                    if index == onboardingPages.count - 1 {
                                        navigateToSignedOutView = true
                                    } else {
                                        withAnimation {
                                            currentPage += 1
                                        }
                                    }
                                })
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .animation(.easeInOut, value: currentPage)
                        .transition(.slide)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: SignedOutView(), isActive: $navigateToSignedOutView) {
                    EmptyView()
                }
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
    let buttonText: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Image(page.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height * 0.5) // 50% of the page height
                    .scaleEffect(isAnimating ? 1 : 0.5)
                
                Spacer()
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isAnimating ? 1 : 0)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .opacity(isAnimating ? 1 : 0)
                
                Spacer()
                
                if(isLastPage) {
                    Button(action: action) {
                        Text(page.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accentColor)
                            .foregroundColor(AppColors.textColor)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.accentColor, lineWidth: isLastPage ? 0 : 2)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                else {
                    Button(action: action) {
                        HStack {
                            Text(page.buttonText)
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding()
                        .foregroundColor(AppColors.accentColor)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}
