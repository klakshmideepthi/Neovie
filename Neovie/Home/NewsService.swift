import Foundation
import Firebase
import FirebaseFirestore

class NewsService: ObservableObject {
    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    private var db = Firestore.firestore()
    
    func fetchNews() {
        isLoading = true
        print("Fetching news...")
        db.collection("news").order(by: "pubDate", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                defer {
                    self.isLoading = false
                }
                
                if let error = error {
                    print("Error fetching news: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found in the 'news' collection")
                    return
                }
                
                print("Number of documents fetched: \(documents.count)")
                
                self.articles = documents.compactMap { document -> NewsArticle? in
                    do {
                        let article = try document.data(as: NewsArticle.self)
//                        print("Successfully parsed article: \(article.title)")
                        return article
                    } catch {
                        print("Error parsing document \(document.documentID): \(error.localizedDescription)")
                        print("Document data: \(document.data())")
                        return nil
                    }
                }
                
                print("Total articles after parsing: \(self.articles.count)")
            }
        }
    }
}
