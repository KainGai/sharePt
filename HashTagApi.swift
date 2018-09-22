import Foundation
import FirebaseDatabase
class HashTagApi {
    let REF_HASHTAG = FIRDatabase.database().reference().child(("hashTag"))
    func retrievePostID(hashTag: String, onSuccess: @escaping (String) -> Void) {
        REF_HASHTAG.child(hashTag.lowercased()).observe(.childAdded) { (snapshot) in
            onSuccess(snapshot.key)
        }
    }
}
