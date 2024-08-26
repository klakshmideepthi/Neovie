//import SwiftUI
//
//struct ExploreView: View {
//    @StateObject private var healthKitManager = HealthKitManager.shared
//    @StateObject private var newsService = NewsService()
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    stepsSection
//                    newsSection
//                }
//                .padding()
//            }
//            .navigationTitle("Explore")
//            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
//        }
//        .onAppear {
//            fetchData()
//        }
//    }
//    
//    private var newsSection: some View {
//        VStack(alignment: .leading) {
//            Text("Latest News")
//                .font(.title2)
//                .padding(.bottom)
//            
//            if newsService.isLoading {
//                ProgressView()
//                    .frame(maxWidth: .infinity, alignment: .center)
//            } else if newsService.articles.isEmpty {
//                Text("No news articles available")
//                    .foregroundColor(.gray)
//            } else {
//                ForEach(newsService.articles) { article in
//                    NewsArticleView(article: article)
//                        .padding(.bottom, 10)
//                }
//            }
//        }
//    }
//    
//    private func fetchData() {
//        healthKitManager.requestAuthorization { success, error in
//            if success {
//                healthKitManager.fetchTodaySteps()
//            } else if let error = error {
//                print("HealthKit authorization failed: \(error.localizedDescription)")
//            }
//        }
//        
//        newsService.fetchNews()
//        }
//    
//    private var stepsSection: some View {
//        VStack(alignment: .center) {
//            Text("Today's Steps")
//                .font(.title)
//                .padding()
//            
//            Text("\(healthKitManager.steps)")
//                .font(.system(size: 48, weight: .bold))
//                .padding()
//            
//            Button("Refresh Steps") {
//                healthKitManager.fetchTodaySteps()
//            }
//            .padding()
//        }
//    }
//    
//}
//
//struct NewsArticleView: View {
//    let article: NewsArticle
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(article.title)
//                .font(.headline)
//                .foregroundColor(AppColors.textColor)
//            
//            if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
//                AsyncImage(url: url) { image in
//                    image.resizable().aspectRatio(contentMode: .fit)
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(height: 200)
//            }
//            
//            Text(article.description)
//                .font(.subheadline)
//                .lineLimit(3)
//            
//            Text("By \(article.author) - \(article.publisher)")
//                .font(.caption)
//                .foregroundColor(.gray)
//            
//            Text("Published: \(article.pubDate)")
//                .font(.caption)
//                .foregroundColor(.gray)
//            
//            Text("Category: \(article.category)")
//                .font(.caption)
//                .foregroundColor(.gray)
//            
//            Button("Read More") {
//                if let url = URL(string: article.url) {
//                    UIApplication.shared.open(url)
//                }
//            }
//            .foregroundColor(AppColors.accentColor)
//        }
//        .padding()
//        .background(AppColors.secondaryBackgroundColor)
//        .cornerRadius(10)
//    }
//}
