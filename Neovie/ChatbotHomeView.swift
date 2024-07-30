import SwiftUI

struct ChatbotHomeView: View {
    @State private var showNewChat = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Helpyy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("Updates")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        UpdateCard(title: "Today's medication", description: "Remember to take your daily dose")
                        
                        Text("Chat history")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(1...6, id: \.self) { _ in
                            ChatHistoryItem()
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
                
                VStack {
                    Spacer()
                    Button(action: {
                        showNewChat = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(hex: 0x708E99))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showNewChat) {
            ChatbotView()
        }
    }
}

struct UpdateCard: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ChatHistoryItem: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Last conversation")
                    .font(.headline)
                Text("2 hours ago")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

