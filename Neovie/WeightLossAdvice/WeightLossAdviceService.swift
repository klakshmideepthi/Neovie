import Foundation
import Firebase
import FirebaseFunctions

class WeightLossAdviceService {
    private let functions = Functions.functions(region: "us-west1")
    
    func getWeightLossAdvice(for userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Calling generateWeightLossPlan with userId: \(userId)")
        
        functions.httpsCallable("generateWeightLossPlan").call(["userId": userId]) { result, error in
            if let error = error {
                print("Error calling generateWeightLossPlan: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("Received result from generateWeightLossPlan: \(String(describing: result?.data))")
            
            if let response = result?.data as? String {
                let parsedResponse = self.parseWeightLossPlan(response)
                completion(.success(parsedResponse))
            } else {
                print("Unexpected response format: \(String(describing: result?.data))")
                completion(.failure(NSError(domain: "WeightLossAdviceService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected response format"])))
            }
        }
    }
    
    private func parseWeightLossPlan(_ response: String) -> String {
        let startTag = "<weight_loss_plan>"
        let endTag = "</weight_loss_plan>"
        
        guard let startRange = response.range(of: startTag),
              let endRange = response.range(of: endTag) else {
            return response
        }
        
        let contentStartIndex = response.index(startRange.upperBound, offsetBy: 0)
        let contentEndIndex = endRange.lowerBound
        
        return String(response[contentStartIndex..<contentEndIndex])
    }
}
