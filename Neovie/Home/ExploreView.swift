import SwiftUI
import SafariServices

struct ExploreView: View {
    @StateObject private var newsService = NewsService()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    newsSection
                }
                .padding()
            }
            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            newsService.fetchNews()
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
}

struct NewsArticleView: View {
    let article: NewsArticle
    @State private var showSafari = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            
            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }
            
            Text(article.description)
                .font(.subheadline)
                .lineLimit(3)
            
            Text("By \(article.publisher)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Published: \(article.pubDate)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Category: \(article.category)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("Read More") {
                showSafari = true
            }
            .foregroundColor(AppColors.accentColor)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(10)
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: article.url) ?? URL(string: "https://www.example.com")!)
        }
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
