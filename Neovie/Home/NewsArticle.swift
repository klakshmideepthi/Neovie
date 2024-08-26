import Foundation
import FirebaseFirestore

struct NewsArticle: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    let title: String
    let description: String
    let url: String
    let imageUrl: String?
    let pubDate: String
    let author: String
    let publisher: String
    let country: String
    let category: String
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case url
        case imageUrl
        case pubDate
        case author
        case publisher
        case country
        case category
        case language
    }
    
    static func == (lhs: NewsArticle, rhs: NewsArticle) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.url == rhs.url &&
               lhs.imageUrl == rhs.imageUrl &&
               lhs.pubDate == rhs.pubDate &&
               lhs.author == rhs.author &&
               lhs.publisher == rhs.publisher &&
               lhs.country == rhs.country &&
               lhs.category == rhs.category &&
               lhs.language == rhs.language
    }
}
