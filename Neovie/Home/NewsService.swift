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

    func fetchNewsAsync() async {
        await MainActor.run { isLoading = true }
        print("Fetching news asynchronously...")

        do {
            let querySnapshot = try await db.collection("news").order(by: "pubDate", descending: true).getDocuments()
            
            let documents = querySnapshot.documents
            print("Number of documents fetched: \(documents.count)")

            let newArticles = documents.compactMap { document -> NewsArticle? in
                do {
                    return try document.data(as: NewsArticle.self)
                } catch {
                    print("Error parsing document \(document.documentID): \(error.localizedDescription)")
                    print("Document data: \(document.data())")
                    return nil
                }
            }

            await MainActor.run {
                self.articles = newArticles
                self.isLoading = false
            }

            print("Total articles after parsing: \(newArticles.count)")
        } catch {
            print("Error fetching news: \(error.localizedDescription)")
            await MainActor.run { self.isLoading = false }
        }
    }
}
