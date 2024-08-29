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
    @ObservedObject var viewModel: HomePageViewModel
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            if viewModel.isFetchingBanners {
                ProgressView("Loading banners...")
            } else if let error = viewModel.bannerFetchError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if bannerContents.isEmpty {
                EmptyBannerView()
            } else {
                BannerContentView(
                    bannerContents: bannerContents,
                    currentIndex: $currentIndex,
                    actionHandler: actionHandler
                )
            }
        }
        .frame(height: 200)
        .onReceive(timer) { _ in
            guard !bannerContents.isEmpty else { return }
            withAnimation {
                currentIndex = (currentIndex + 1) % bannerContents.count
            }
        }
    }
}

struct EmptyBannerView: View {
    var body: some View {
        Text("No banners available")
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
    }
}

struct BannerContentView: View {
    let bannerContents: [BannerContent]
    @Binding var currentIndex: Int
    let actionHandler: (String) -> Void
    
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
            .frame(maxWidth:.infinity)
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
        .shadow(radius: 5)
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
                
                if let image = UIImage(named: content.imageName) {
                    Image(uiImage: image)
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(height: 180)
                       .padding(.horizontal, 5)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 180)
                        .padding(.horizontal, 5)
                        .foregroundColor(.gray)
                }
            }
        }
        .clipped()
    }
}
    
    
