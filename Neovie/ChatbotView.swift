import SwiftUI


struct ChatbotView: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var messages: [ChatMessage] = []
        @State private var newMessage: String = ""
        @State private var isLoading: Bool = false
        @State private var errorMessage: String? = nil
        
    private let anthropicService = AnthropicService(apiKey: "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")

        var body: some View {
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    Spacer()
                    Text("Chat with Helpyy")
                        .font(.headline)
                    Spacer()
                    Color.clear.frame(width: 22, height: 22)
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 1)

                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("Message Helpyy...", text: $newMessage)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .disabled(isLoading || newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.4))
                            .edgesIgnoringSafeArea(.all)
                    }
                }
            )
            .alert(item: Binding(
                get: { errorMessage.map { ErrorWrapper(error: $0) } },
                set: { errorMessage = $0?.error }
            )) { errorWrapper in
                Alert(title: Text("Error"), message: Text(errorWrapper.error), dismissButton: .default(Text("OK")))
            }
        }

        func sendMessage() {
            guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            let userMessage = ChatMessage(content: newMessage, isUser: true)
            messages.append(userMessage)
            
            isLoading = true
            anthropicService.sendMessage(newMessage) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let response):
                        print("Received successful response: \(response)")
                        let botResponse = ChatMessage(content: response, isUser: false)
                        messages.append(botResponse)
                    case .failure(let error):
                        print("Error in ChatbotView: \(error.localizedDescription)")
                        errorMessage = error.localizedDescription
                        let errorChatMessage = ChatMessage(content: "Error: Unable to get response. Please try again.", isUser: false)
                        messages.append(errorChatMessage)
                    }
                }
            }
            
            newMessage = ""
        }
    }

    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
    }

    struct ChatBubble: View {
        let message: ChatMessage
        @State private var userProfile = UserProfile()
        
        var body: some View {
            HStack(alignment: .bottom, spacing: 8) {
                if !message.isUser {
                    Image(systemName: "person.fill.viewfinder")
                        .foregroundColor(Color(hex: 0x708E99))
                        .font(.system(size: 24))
                }
                
                if message.isUser {
                    Spacer()
                }
                
                Text(message.content)
                    .padding(10)
                    .background(message.isUser ? Color(hex: 0x949E94): Color.gray.opacity(0.2))
                    .foregroundColor(message.isUser ? .white : .black)
                    .cornerRadius(20)
                
                if message.isUser {
                    let firstLetter = getFirstLetter()
                    Image(systemName: "figure.wave")
                        .foregroundColor(Color(hex: 0x708E99))
                        .font(.system(size: 24))
                } else {
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
        }
        private func getFirstLetter() -> String {
                let name = userProfile.name
                let firstLetter = String(name.prefix(1))
                print(userProfile.name) // Debug print statement
                return firstLetter
            }
    }

    struct ErrorWrapper: Identifiable {
        let id = UUID()
        let error: String
    }

