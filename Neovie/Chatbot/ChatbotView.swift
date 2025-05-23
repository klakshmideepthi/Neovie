import SwiftUI
import Firebase
import FirebaseFunctions
import Combine
import FirebaseAnalytics

struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatbotViewModel()
    @State private var inputMessage = ""
    @State private var keyboardHeight: CGFloat = 0
    let initialPrompt: String?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    customNavigationBar
                    chatMessagesView
                    inputField(geometry: geometry)
                }
                .padding(.bottom, keyboardHeight)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            addKeyboardObservers()
            Analytics.logEvent("chatbot_session_start", parameters: nil)
            if let prompt = initialPrompt {
                viewModel.sendMessage(prompt)
            }
        }
        .onDisappear(perform: removeKeyboardObservers)
    }
    
    private var customNavigationBar: some View {
        HStack {
            Text("New Thread")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(AppColors.textColor.opacity(0.6))
                    .font(.system(size: 22))
            }
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
    }
    
    private var chatMessagesView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 10) {
                    if viewModel.messages.isEmpty && viewModel.currentStreamingMessage == nil {
                        Image("mega-creator")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.top, UIScreen.main.bounds.height / 4)
                    } else {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                        if let streamingMessage = viewModel.currentStreamingMessage {
                            ChatBubble(message: streamingMessage)
                        }
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        Color.clear.frame(height: 1).id("bottomAnchor")
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.scrollToBottom) { _ in
                withAnimation {
                    scrollView.scrollTo("bottomAnchor", anchor: .bottom)
                }
            }
            .background(AppColors.backgroundColor)
        }
    }
    
    private func inputField(geometry: GeometryProxy) -> some View {
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
                    .disabled(viewModel.isLoading)
                    .accentColor(AppColors.accentColor)
                
                Button(action: { viewModel.sendMessage(inputMessage); inputMessage = "" }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(inputMessage.isEmpty || viewModel.isLoading ? AppColors.textColor.opacity(0.3) : .white)
                        .padding(15)
                        .background(inputMessage.isEmpty || viewModel.isLoading ? AppColors.secondaryBackgroundColor : AppColors.accentColor)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppColors.textColor.opacity(0.3), lineWidth: 1)
                        )
                }
                .disabled(inputMessage.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
        .background(AppColors.secondaryBackgroundColor)
        .padding(.bottom, geometry.safeAreaInsets.bottom)
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

class ChatbotViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var scrollToBottom = false
    @Published var currentStreamingMessage: ChatMessage?
    
    private let anthropicService = AnthropicService()
    
    func sendMessage(_ messageToSend: String) {
        guard !messageToSend.isEmpty else { return }
        
        let userMessage = ChatMessage(content: messageToSend, isUser: true)
        messages.append(userMessage)
        print("Added user message: \(userMessage.content)")
        scrollToBottom.toggle()
        
        isLoading = true
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            isLoading = false
            displayErrorMessage("User not authenticated. Please sign in and try again.")
            return
        }
        
        currentStreamingMessage = ChatMessage(content: "", isUser: false)
        
        anthropicService.sendMessage(messageToSend, userId: userId, onPartialResponse: { [weak self] partialResponse in
            print("Received partial response: \(partialResponse)")
            DispatchQueue.main.async {
                self?.currentStreamingMessage?.content += partialResponse
                self?.scrollToBottom.toggle()
            }
        }) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    if let finalMessage = self?.currentStreamingMessage {
                        print("Adding final message to chat: \(finalMessage.content)")
                        self?.messages.append(finalMessage)
                        self?.currentStreamingMessage = nil
                    } else {
                        print("No final message to display")
                    }
                case .failure(let error):
                    self?.handleError(error)
                }
                
                self?.scrollToBottom.toggle()
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let errorMessage: String
        
        if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
                switch FunctionsErrorCode(rawValue: error.code) {
                case .some(.internal):
                    errorMessage = "An internal error occurred. Please try again later or contact support if the issue persists."
                case .some(.unavailable):
                    errorMessage = "The service is currently unavailable. Please try again later."
                case .some(.resourceExhausted):
                    errorMessage = "You've reached the usage limit. Please try again later or upgrade your plan."
                default:
                    errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                }
            } else {
                errorMessage = "An error occurred: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        print("Error occurred: \(errorMessage)")
        displayErrorMessage(errorMessage)
    }
    
    private func displayErrorMessage(_ message: String) {
        let errorMessage = ChatMessage(content: "Error: \(message)", isUser: false)
        messages.append(errorMessage)
        print("Added error message: \(errorMessage.content)")
    }
}
