import Foundation
import FirebaseDatabase
class FollowApi {
    let REF_FOLLOWER = FIRDatabase.database().reference().child("follower")
    let REF_FOLLOWING = FIRDatabase.database().reference().child("following")
    func observeAllFollowers(uid: String, completion: @escaping (_ followerId: String) -> Void) {
        REF_FOLLOWER.child(uid).observe(.childAdded) { (snapshot) in
            completion(snapshot.key)
        }
    }
    func followAction(uid: String) {
        guard let currentUserID = Api.USER.CURRENT_USER?.uid else { return }
        REF_FOLLOWER.child(uid).child(currentUserID).setValue(true)
        REF_FOLLOWING.child(currentUserID).child(uid).setValue(true)
        Api.USER_POST.REF_USER_POST.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                for key in dict.keys {
                    Api.POST.observeSinglePost(postId: key, completion: { (post) in
                        Api.FEED.saveNewFeed(uid: currentUserID, postId: key, timestamp: post.timestamp!)
                    })                    
                }
            }
        })
    }
    func unFollowAction(uid: String) {
        guard let currentUserID = Api.USER.CURRENT_USER?.uid else { return }
        REF_FOLLOWER.child(uid).child(currentUserID).setValue(NSNull())
        REF_FOLLOWING.child(currentUserID).child(uid).setValue(NSNull())
        Api.USER_POST.REF_USER_POST.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                for key in dict.keys {
                    Api.FEED.removeFeed(uid: currentUserID, postId: key)
                }
            }
        })
    }
    func checkFollowing(uid: String, completion: @escaping (Bool) -> Void) {
        REF_FOLLOWER.child(uid).child((Api.USER.CURRENT_USER?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull{
                completion(false)
            }else {
                completion(true)
            }
        })
    }
    func observeFollowerCount(uid: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWER.child(uid).observe(.value, with: { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
    func observeFollowingCount(uid: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(uid).observe(.value, with: { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        })
    }
}
