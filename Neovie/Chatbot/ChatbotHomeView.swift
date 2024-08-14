import SwiftUI

struct ChatbotHomeView: View {
    @State private var isShowingChatbot = false
    @State private var selectedPrompt: String?
    
    let prompts: [(String, String)] = [
        ("The founding story of McDonalds", "building.2"),
        ("The tallest Ferris wheel", "circle"),
        ("Did dinosaurs go extinct?", "fossil.shell"),
        ("The origins of a joker card", "suit.club.fill"),
        ("Are all mushrooms edible?", "leaf.fill")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text("Your personalized AI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textColor)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(prompts, id: \.0) { prompt in
                            TopicButton(title: prompt.0, icon: prompt.1)
                                .onTapGesture {
                                    selectedPrompt = prompt.0
                                    isShowingChatbot = true
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    selectedPrompt = nil
                    isShowingChatbot = true
                }) {
                    Text("Ask me anything!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accentColor)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        }
        .sheet(isPresented: $isShowingChatbot) {
            ChatbotView(initialPrompt: selectedPrompt)
        }
    }
}

struct TopicButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(AppColors.accentColor)
                .font(.system(size: 24))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .aspectRatio(1, contentMode: .fit)
            
            Text(title)
                .foregroundColor(AppColors.textColor)
                .font(.body)
                .lineLimit(1)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textColor.opacity(0.6))
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(15)
        .shadow(color: AppColors.textColor.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(10)
                .background(message.isUser ? AppColors.accentColor : AppColors.secondaryBackgroundColor)
                .foregroundColor(message.isUser ? .white : AppColors.textColor)
                .cornerRadius(10)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
