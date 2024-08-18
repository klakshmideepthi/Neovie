import SwiftUI

struct BannerContent: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let buttonText: String
    let backgroundColor: Color
    let imageName: String
    let actionIdentifier: String
}

struct BannerView: View {
    let bannerContents: [BannerContent]
    @State private var currentIndex = 0
    let actionHandler: (String) -> Void
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 10) {
            TabView(selection: $currentIndex) {
                ForEach(bannerContents.indices, id: \.self) { index in
                    bannerCard(bannerContents[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
            .cornerRadius(20)
            
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<bannerContents.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding()
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % bannerContents.count
            }
        }
    }
    
    private func bannerCard(_ content: BannerContent) -> some View {
        ZStack(alignment: .trailing) {
            content.backgroundColor
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(content.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(content.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    Button(action: {
                        actionHandler(content.actionIdentifier)
                    }) {
                        Text(content.buttonText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(20)
                    }
                }
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .leading)
                
                Spacer()
                
                Image(content.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
            }
        }
        .clipped()
    }
}
