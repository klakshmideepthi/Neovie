import SwiftUI
import SafariServices

struct ExploreView: View {
    @StateObject private var newsService = NewsService()
    @State private var isRefreshing = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    newsSection
                }
                .padding()
            }
            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
            .refreshable {
                await refreshNews()
            }
        }
        .onAppear {
            if newsService.articles.isEmpty {
                newsService.fetchNews()
            }
        }
    }
    
    private var newsSection: some View {
        VStack(alignment: .leading) {
            Text("Latest News")
                .font(.title2)
                .padding(.bottom)
            
            if newsService.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if newsService.articles.isEmpty {
                Text("No news articles available")
                    .foregroundColor(.gray)
            } else {
                ForEach(newsService.articles) { article in
                    NewsArticleView(article: article)
                        .padding(.bottom, 10)
                }
            }
        }
    }

    private func refreshNews() async {
        isRefreshing = true
        await newsService.fetchNewsAsync()
        isRefreshing = false
    }
}

struct NewsArticleView: View {
    let article: NewsArticle
    @State private var showSafari = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(article.publisher)
                .font(.headline)
                .foregroundColor(AppColors.accentColor)
            
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.headline )
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textColor)
                        .lineLimit(3)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                    }
                }
            }
            .frame(height: 100)
            
            Divider()
                .background(Color.gray)
            
            HStack {
                Text(formattedDate(article.pubDate))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
//                Image(systemName: "ellipsis")
//                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(15)
        .onTapGesture {
            showSafari = true
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: article.url) ?? URL(string: "https://www.example.com")!)
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}
