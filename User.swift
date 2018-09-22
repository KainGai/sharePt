import Foundation
class User {
    var uid: String?
    var username: String?
    var email: String?
    var profileImageUrl: String?
    var isFollowing: Bool?
    var info: String?
    static func convertUserInfo(dict: [String: AnyObject], uid: String) -> User {
        let user = User()
        user.uid = uid
        user.profileImageUrl = dict["profileImageURL"] as? String
        user.username = dict["username"] as? String
        user.email = dict["email"] as? String
        user.info = dict["info"] as? String
        return user
    }
}
