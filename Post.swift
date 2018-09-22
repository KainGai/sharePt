import Foundation
class Post {
    var caption: String?
    var photoUrl: String?
    var videoUrl: String?
    var uid: String?
    var postId: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var thumbnailUrl: String?
    var timestamp: Int?
    static func convertPostPhoto(dict: [String: AnyObject], id: String) -> Post {
        let post = Post()
        post.postId = id
        post.caption = dict["caption"] as? String
        post.photoUrl = dict["photoUrl"] as? String
        post.thumbnailUrl = dict["thumbnailUrl"] as? String
        post.videoUrl = dict["videoUrl"] as? String
        post.uid = dict["uid"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.timestamp = dict["timestamp"] as? Int
        post.likes = dict["likes"] as? Dictionary<String,Any>
        if let uid = Api.USER.CURRENT_USER?.uid {
            if post.likes?[uid] != nil {
                post.isLiked = true
            }else {
                post.isLiked = false
            }
        }
        return post
    }
}
