import SwiftUI

struct ChatbotHomeView: View {
    @State private var _isShowingChatbot = false
    @State private var selectedPrompt: String?
    
    var isShowingChatbot: Binding<Bool> {
        Binding(
            get: { _isShowingChatbot },
            set: { newValue in
                if !newValue {
                    // Reset selectedPrompt when closing the sheet
                    selectedPrompt = nil
                }
                _isShowingChatbot = newValue
            }
        )
    }
    
    let prompts: [(String, String)] = [
        ("The founding story of McDonalds", "building.2"),
        ("The tallest Ferris wheel", "circle"),
        ("Did dinosaurs go extinct?", "fossil.shell"),
        ("Are all mushrooms edible?", "leaf.fill")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Text("Your personalized AI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textColor)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(prompts, id: \.0) { prompt in
                            TopicButton(title: prompt.0, icon: prompt.1)
                                .onTapGesture {
                                    presentChatbot(with: prompt.0)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
                
                Button(action: {
                    presentChatbot(with: nil)
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
        .sheet(isPresented: isShowingChatbot) {
            ChatbotView(initialPrompt: selectedPrompt)
        }
    }
    
    private func presentChatbot(with prompt: String?) {
        selectedPrompt = prompt
        _isShowingChatbot = true
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

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var content: String
    let isUser: Bool
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
    }
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
