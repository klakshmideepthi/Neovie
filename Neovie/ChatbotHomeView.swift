import SwiftUI

struct ChatbotHomeView: View {
    @State private var isShowingChatbot = false
    @State private var searchText = ""
    
    let prompts: [(String, String)] = [
        (" The founding story of McDonalds", "building.2"),
        (" The tallest Ferris wheel", "circle"),
        (" Did dinosaurs go extinct?", "fossil.shell"),
        (" The origins of a joker card", "suit.club.fill"),
        (" Are all mushrooms edible?", "leaf.fill")
    ]
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    
                    VStack(spacing: 10) {
                        
                        Spacer()
                    
                        Text("Your personalized AI")
                            .font(.title)
                        Spacer().frame(height: 10)
                        
                        ForEach(prompts, id: \.0) { prompt in
                            TopicButton(title: prompt.0, icon: prompt.1)
                                .onTapGesture {
                                    searchText = prompt.0
                                    isShowingChatbot = true
                                }
                        }
                    
                        
                        Spacer()
                        
                        Button(action: {
                                    isShowingChatbot = true
                        }) {
                            HStack {
                                Text("Ask me anything!!")
                                    .foregroundColor(.gray)
                                     .padding()
                                
                                Spacer()
                            }
                             .frame(height: 50)
                             .background(Color.gray.opacity(0.1))
                             .cornerRadius(20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                }
                .background(Color(hex: 0xEDEDED))
            }
            .sheet(isPresented: $isShowingChatbot) {
                ChatbotView()
            }
        }
    }
}

struct TopicButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: 0xC67C4E))
                .font(.system(size: 20))
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(.gray)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 10)
        .frame(width: UIScreen.main.bounds.width * 0.85 - 4, height: 50) // Subtract 4 to account for the 2px border on each side
        .background(Color.white) // White background
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: 0x313131), lineWidth: 2) // Black border
        )
        .cornerRadius(10)
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
                .background(message.isUser ? Color(hex: 0xC67C4E) : Color.gray)
                .foregroundColor(.white)
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
