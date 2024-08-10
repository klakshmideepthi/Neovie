import SwiftUI
import Firebase
import Combine

struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [ChatMessage] = []
    @State private var inputMessage = ""
    @State private var isLoading = false
    @State private var scrollToBottom = false
    @State private var keyboardHeight: CGFloat = 0 // New state variable
    
    private let anthropicService = AnthropicService()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Text("New Thread")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 22))
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    
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
                        .background(Color(hex: 0xEDEDED))
                    }
                    
                    // Input field
                    VStack {
                        HStack {
                            TextField("Ask anything...", text: $inputMessage)
                                .padding(15)
                                .background(Color(hex: 0xEDEDED))
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .disabled(isLoading)
                                .accentColor(Color(hex: 0x313131))
                            
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(inputMessage.isEmpty || isLoading ? Color(hex: 0x9B9B9B) : .white)
                                    .padding(15)
                                    .background(inputMessage.isEmpty || isLoading ? Color(hex: 0xEDEDED) : Color(hex: 0xC67C4E))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .disabled(inputMessage.isEmpty || isLoading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    }
                    .background(Color.white)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
                .padding(.bottom, keyboardHeight) // Add padding to lift the content
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: addKeyboardObservers)
        .onDisappear(perform: removeKeyboardObservers)
    }
    
    private func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        
        let userMessage = ChatMessage(content: inputMessage, isUser: true)
        messages.append(userMessage)
        scrollToBottom.toggle()
        
        let sentMessage = inputMessage
        inputMessage = "" // Clear the input field immediately
        
        isLoading = true
        
        // Get the current user's ID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            isLoading = false
            return
        }
        
        anthropicService.sendMessage(sentMessage, userId: userId) { result in
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
        
        // New function to remove keyboard observers
        private func removeKeyboardObservers() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
}
