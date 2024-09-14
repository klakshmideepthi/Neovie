import SwiftUI

struct ChatbotHomeView: View {
    @State private var _isShowingChatbot = false
    @State private var selectedPrompt: String?
    
    var isShowingChatbot: Binding<Bool> {
        Binding(
            get: { _isShowingChatbot },
            set: { newValue in
                if !newValue {
                    selectedPrompt = nil
                }
                _isShowingChatbot = newValue
            }
        )
    }
    
    let prompts: [(String, String)] = [
        ("Benefits of cardio exercise", "heart.circle"),
        ("Best foods for muscle growth", "fork.knife"),
        ("How to start strength training", "figure.walk"),
        ("Tips for better sleep", "bed.double.fill")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                Spacer()
                
                Text("Your personalized AI")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textColor)
                
                promptsView
                
                Spacer()
                
                askMeAnythingButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        }
        .sheet(isPresented: isShowingChatbot) {
            ChatbotView(initialPrompt: selectedPrompt)
        }
    }
    
    private var promptsView: some View {
        VStack(spacing: 15) {
            ForEach(prompts, id: \.0) { prompt in
                TopicButton(title: prompt.0, icon: prompt.1)
                    .onTapGesture {
                        presentChatbot(with: prompt.0)
                    }
            }
        }
    }
    
    private var askMeAnythingButton: some View {
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
                .frame(width: 40, height: 40)
            
            Text(title)
                .foregroundColor(AppColors.textColor)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textColor.opacity(0.6))
        }
        .padding()
        .frame(height: 60)
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
