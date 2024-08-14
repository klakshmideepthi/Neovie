import SwiftUI
import Firebase
import Combine

struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var inputMessage = ""
    @State private var isLoading = false
    @State private var scrollToBottom = false
    @State private var keyboardHeight: CGFloat = 0
    let initialPrompt: String?
    
    private let anthropicService = AnthropicService()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Text("New Thread")
                            .font(.headline)
                            .foregroundColor(AppColors.textColor)
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.textColor.opacity(0.6))
                                .font(.system(size: 22))
                        }
                    }
                    .padding()
                    .background(AppColors.secondaryBackgroundColor)
                    
                    // Chat messages
                    ScrollViewReader { scrollView in
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                if messages.isEmpty {
                                    Image("mega-creator")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .padding(.top, geometry.size.height / 4)
                                } else {
                                    ForEach(messages) { message in
                                        ChatBubble(message: message)
                                    }
                                    if isLoading {
                                        ProgressView()
                                            .padding()
                                    }
                                    Color.clear.frame(height: 1).id("bottomAnchor")
                                }
                            }
                            .padding()
                        }
                        .onChange(of: scrollToBottom) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomAnchor", anchor: .bottom)
                            }
                        }
                        .background(AppColors.backgroundColor)
                    }
                    
                    // Input field
                    VStack {
                        HStack {
                            TextField("Ask anything...", text: $inputMessage)
                                .padding(15)
                                .background(AppColors.secondaryBackgroundColor)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(AppColors.textColor.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(isLoading)
                                .accentColor(AppColors.accentColor)
                            
                            Button(action: { sendMessage() }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(inputMessage.isEmpty || isLoading ? AppColors.textColor.opacity(0.3) : .white)
                                    .padding(15)
                                    .background(inputMessage.isEmpty || isLoading ? AppColors.secondaryBackgroundColor : AppColors.accentColor)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(AppColors.textColor.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .disabled(inputMessage.isEmpty || isLoading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    .background(AppColors.secondaryBackgroundColor)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
                .padding(.bottom, keyboardHeight)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            addKeyboardObservers()
            if let prompt = initialPrompt {
                sendMessage(prompt)
            }
        }
        .onDisappear(perform: removeKeyboardObservers)
    }
    
    private func sendMessage(_ message: String = "") {
        let messageToSend = message.isEmpty ? inputMessage : message
        guard !messageToSend.isEmpty else { return }
        
        let userMessage = ChatMessage(content: messageToSend, isUser: true)
        messages.append(userMessage)
        scrollToBottom.toggle()
        
        inputMessage = "" // Clear the input field
        isLoading = true
        
        // Get the current user's ID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            isLoading = false
            return
        }
        
        anthropicService.sendMessage(messageToSend, userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let response):
                    let botMessage = ChatMessage(content: response, isUser: false)
                    messages.append(botMessage)
                case .failure(let error):
                    let errorMessage = ChatMessage(content: "Error: \(error.localizedDescription)", isUser: false)
                    messages.append(errorMessage)
                }
                
                scrollToBottom.toggle()
            }
        }
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
