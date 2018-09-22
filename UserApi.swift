import Foundation
import FirebaseDatabase
import FirebaseAuth
class UserApi {
    let REF_USERS = FIRDatabase.database().reference().child("users")
    var CURRENT_USER: FIRUser? {
        if let user = FIRAuth.auth()?.currentUser {
            return user
        }else {
            return nil
        }
    }
    func userStateChangeListener(completion: @escaping (FIRUser) -> Void) {
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            if let user = user {
                completion(user)
            }
        })
    }
	func observeUsers(uid: String, completion:  @escaping (User) -> Void) {
		self.REF_USERS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
			if let dict = snapshot.value as? [String : AnyObject] {
				let user = User.convertUserInfo(dict: dict, uid: snapshot.key)
				completion(user)
			}
		})
    }
    func observeAllUsers(completion: @escaping (User) -> Void) {
        REF_USERS.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let user = User.convertUserInfo(dict: dict, uid: snapshot.key)
                if user.uid != Api.USER.CURRENT_USER?.uid {
                    completion(user)
                }
            }
        })
    }
    func observeCurrentUser(completion: @escaping (User) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let user = User.convertUserInfo(dict: dict, uid: snapshot.key)
                completion(user)
            }
        })
    }
    func observeCurrentUserId(completion: @escaping (String) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return
        }
        completion(currentUser.uid)
    }
    func queryUser(text: String, completion: @escaping (User) -> Void) {
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text + "\u{f8ff}").observeSingleEvent(of: .value, with: {snapshot in
            snapshot.children.forEach({ (s) in
                let child = s as! FIRDataSnapshot
                if let dict = child.value as? [String : AnyObject] {
                    let user = User.convertUserInfo(dict: dict, uid: child.key)
                    if user.uid != Api.USER.CURRENT_USER?.uid {
                        completion(user)
                    }
                }
            })
        })
    }
    func retrieveUserByUserName(username: String, onSuccess: @escaping (User) -> Void) {
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryEqual(toValue: username).observeSingleEvent(of: .childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let user = User.convertUserInfo(dict: dict, uid: snapshot.key)
                onSuccess(user)
            }
        })
    }
}
