import Foundation
import FirebaseDatabase
class PostCommentApi {
    let REF_POST_COMMENT = FIRDatabase.database().reference().child("post-comment")
    func observePostComment(postId: String, completion: @escaping (FIRDataSnapshot) -> Void) {
        REF_POST_COMMENT.child(postId).observe(.childAdded, with: { (snapshot) in
            completion(snapshot)
        })
    }
}
