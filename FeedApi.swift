import Foundation
import FirebaseDatabase
class FeedApi {
    let REF_FEED = FIRDatabase.database().reference().child("feed")
    func saveNewFeedAndUpdateFollower(uid: String, postId: String, timestamp: Int) {
        REF_FEED.child(uid).child(postId).setValue(["timestamp" : timestamp])
        Api.FOLLOW.observeAllFollowers(uid: uid) { (follower) in
            self.REF_FEED.child(follower).child(postId).setValue(["timestamp" : timestamp])
        }
    }
    func saveNewFeed(uid: String, postId: String, timestamp: Int) {
        REF_FEED.child(uid).child(postId).setValue(["timestamp" : timestamp])
    }
    func removeFeed(uid: String, postId: String) {
        REF_FEED.child(uid).child(postId).setValue(NSNull())
    }
	func observeNewFeed(withUID uid: String, completion: @escaping (Post) -> Void) {
		REF_FEED.child(uid).queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
			Api.POST.observeSinglePost(postId: snapshot.key, completion: { (post) in
				completion(post)
			})
		}
	}
	func observeFeed(withUID uid: String, pagination: Int, shouldLoadMore: Bool, postCount: Int? = 0, completion: @escaping (Post, User) -> Void, isHiddenIndicator: @escaping (_ isHiddenIndicator: Bool?) -> Void) {
		REF_FEED.child(uid).queryOrdered(byChild: "timestamp").queryLimited(toLast: UInt(pagination)).observeSingleEvent(of: .value, with: { snapshot in
			var items = snapshot.children.allObjects
			if(shouldLoadMore) {
				if(items.count <= postCount!) {
					isHiddenIndicator(true)
					return
				}
				items.removeLast(postCount!)
			}
			let myGroup = DispatchGroup()
			var results = Array(repeating: (Post(), User()), count: items.count)
			for(index, item) in (items as! [FIRDataSnapshot]).enumerated() {
				myGroup.enter()
				Api.POST.observeSinglePost(postId: item.key, completion: { (post) in
					Api.USER.observeUsers(uid: post.uid!, completion: { (user) in
						results[index] = (post, user)
						myGroup.leave()
					})
				})
			}
			myGroup.notify(queue: .main, execute: {
				for result in results {
					completion(result.0, result.1)
				}
			})
		})		
	}
    func observeFeed(uid: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(uid).queryOrdered(byChild: "timestamp").observe(.childAdded, with: { (snapshot) in
			let key = snapshot.key
            Api.POST.observeSinglePost(postId: key, completion: { (post) in
                completion(post)
            })
        })
    }
    func observeFeedRemoved(uid: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(uid).observe(.childRemoved, with: { (snapshot) in
            let key = snapshot.key
            Api.POST.observeSinglePost(postId: key, completion: { (post) in
                completion(post)
            })
        })
    }
}
