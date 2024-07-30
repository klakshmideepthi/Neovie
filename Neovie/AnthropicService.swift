import Foundation

class AnthropicService {
    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    
    init(apiKey: String) {
        self.apiKey = apiKey
        print("AnthropicService initialized with API key: \(apiKey.prefix(8))...")
    }
    
    func sendMessage(_ message: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Sending message to Anthropic API: \(message)")
        
        guard let url = URL(string: baseURL) else {
            print("Error: Invalid URL")
            completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body: [String: Any] = [
            "model": "claude-3-opus-20240229",
            "messages": [
                ["role": "user", "content": message]
            ],
            "max_tokens": 1000
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            print("Request body: \(String(data: jsonData, encoding: .utf8) ?? "")")
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("Sending request to Anthropic API...")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])))
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
//            print("Received data: \(String(data: data, encoding: .utf8) ?? "")")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                    print("Parsed JSON: \(json)")
                    if let content = (json["content"] as? [[String: Any]])?.first?["text"] as? String {
                        print("Successfully extracted response text")
                        completion(.success(content))
                    } else if let error = json["error"] as? [String: Any],
                              let message = error["message"] as? String {
                        print("API Error: \(message)")
                        completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: message])))
                    } else {
                        print("Unexpected JSON structure")
                        completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON structure"])))
                    }
                } else {
                    print("Failed to parse JSON")
                    completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])))
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
