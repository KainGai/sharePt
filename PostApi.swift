import Foundation
import FirebaseDatabase
class PostApi {
    var REF_POSTS = FIRDatabase.database().reference().child("posts")
    func observePosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let post = Post.convertPostPhoto(dict: dict, id: snapshot.key)
                completion(post)
            }
        })
    }
	func observeTopPosts(pagination: Int, shouldLoadMore: Bool, postCount: Int? = 0, completion: @escaping (Post) -> Void) {
		REF_POSTS.queryOrdered(byChild: "likeCount").queryLimited(toLast: UInt(pagination)).observeSingleEvent(of: .value, with: { (snapshot) in
			var snapshotArray = (snapshot.children.allObjects as! [FIRDataSnapshot])
			if(shouldLoadMore) {
				if(snapshotArray.count <= postCount!) {
					return
				}
				snapshotArray.removeLast(postCount!)
			}
			snapshotArray.forEach({ (child) in
				if let dict = child.value as? [String : AnyObject] {
					let post = Post.convertPostPhoto(dict: dict, id: child.key)
					completion(post)
				}
			})
		})
	}
    func observeTopPosts(completion: @escaping (Post) -> Void) {
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value, with: { (snapshot) in
            (snapshot.children).reversed().forEach({ (s) in
                let child = s as! FIRDataSnapshot
                if let dict = child.value as? [String : AnyObject] {
                    let post = Post.convertPostPhoto(dict: dict, id: child.key)
                    completion(post)
                }
            })
        })
    }
    func observeSinglePost(postId: String, completion: @escaping (Post) -> Void) {
        REF_POSTS.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let post = Post.convertPostPhoto(dict: dict, id: snapshot.key)
                completion(post)
            }
        })
    }
    func observeLikeCount(postId: String, completion: @escaping (Int) -> Void) {
        REF_POSTS.child(postId).observe(.childChanged, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                completion(value)
            }
        })
    }
    func increaseLikes(postId: String, onSuccess: @escaping () -> Void, onError: @escaping (Error?) -> Void) {
        let ref = REF_POSTS.child(postId)
        ref.runTransactionBlock({ (currentData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Api.USER.CURRENT_USER?.uid {
                var likes: [String : Bool] = post["likes"] as? [String: Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                }else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likes"] = likes as AnyObject?
                post["likeCount"] = likeCount as AnyObject?
                currentData.value = post
                return FIRTransactionResult.success(withValue: currentData)
            }else {
                return FIRTransactionResult.success(withValue: currentData)
            }
        }) { (error, committed, snapshot) in
            if error != nil {
                onError(error)
                return
            }
            onSuccess()
        }
    }
}
