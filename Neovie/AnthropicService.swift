import Foundation
import FirebaseFunctions

class AnthropicService {
    private let functions = Functions.functions(region: "us-west1")

    func generateWeightLossPlan(userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        functions.httpsCallable("generateWeightLossPlan").call(["userId": userId]) { result, error in
            self.handleFunctionResult(result: result, error: error, completion: completion)
        }
    }

    func sendMessage(_ message: String, userId: String, onPartialResponse: @escaping (String) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
            functions.httpsCallable("callAnthropicAPI").call(["message": message, "userId": userId]) { result, error in
                if let error = error as NSError? {
                    print("Error calling Cloud Function: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let stringResponse = result?.data as? String {
                    // Handle full response
                    onPartialResponse(stringResponse)
                    completion(.success(()))
                } else {
                    let error = NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    completion(.failure(error))
                }
            }
        }
        
        private func startStreaming(streamToken: String, onPartialResponse: @escaping (String) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
            functions.httpsCallable("streamAnthropicResponse").call(["streamToken": streamToken]) { result, error in
                if let error = error {
                    print("Error in streaming: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                print("Raw streaming response data: \(String(describing: result?.data))")
                
                guard let data = result?.data as? [String: Any] else {
                    let error = NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Streaming response data is not a dictionary"])
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let errorMessage = data["error"] as? String {
                    let error = NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    print("Error from streaming server: \(errorMessage)")
                    completion(.failure(error))
                    return
                }
                
                guard let responseChunk = data["responseChunk"] as? String else {
                    let error = NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Response chunk not found in streaming response"])
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                onPartialResponse(responseChunk)
                
                if let isComplete = data["isComplete"] as? Bool, isComplete {
                    completion(.success(()))
                } else {
                    self.startStreaming(streamToken: streamToken, onPartialResponse: onPartialResponse, completion: completion)
                }
            }
        }

    private func handleFunctionResult(result: HTTPSCallableResult?, error: Error?, completion: @escaping (Result<String, Error>) -> Void) {
        if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
                switch FunctionsErrorCode(rawValue: error.code) {
                case .some(.notFound):
                    print("Function not found. Make sure it's deployed to region 'us-west1'")
                case .some(.internal):
                    print("Internal error in Cloud Function. Error details: \(error.localizedDescription)")
                    if let details = error.userInfo[FunctionsErrorDetailsKey] as? [String: Any] {
                        print("Error details: \(details)")
                    }
                default:
                    print("Unexpected error: \(error.localizedDescription)")
                }
            } else {
                print("Error calling Cloud Function: \(error.localizedDescription)")
            }
            completion(.failure(error))
            return
        }
        
        print("Received response from Cloud Function. Data: \(String(describing: result?.data))")
        
        if let response = self.parseResponse(result?.data) {
            print("Successfully parsed response: \(response)")
            completion(.success(response))
        } else {
            print("Failed to parse response")
            completion(.failure(NSError(domain: "AnthropicService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])))
        }
    }

    private func parseResponse(_ data: Any?) -> String? {
        if let responseString = data as? String {
            return responseString
        } else if let responseDict = data as? [String: Any],
                  let response = responseDict["response"] as? String {
            return response
        } else if let responseDict = data as? [String: Any],
                  let choices = responseDict["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let text = firstChoice["text"] as? String {
            return text
        }
        
        print("Unhandled response format: \(String(describing: data))")
        return nil
    }
}
