import Contacts

class UserNameManager {
    static let shared = UserNameManager()
    
    private init() {}
    
    func fetchUserName(completion: @escaping (String?) -> Void) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                print("Access to contacts denied")
                completion(nil)
                return
            }
            
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            request.predicate = CNContact.predicateForContacts(matchingName: "me")
            
            do {
                var userName: String?
                try store.enumerateContacts(with: request) { contact, _ in
                    userName = contact.givenName
                }
                completion(userName)
            } catch {
                print("Error fetching user's contact: \(error)")
                completion(nil)
            }
        }
    }
}
