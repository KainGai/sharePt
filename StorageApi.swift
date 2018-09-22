import Foundation
import FirebaseStorage
import FirebaseDatabase
class StorageApi {
    let REF_STORAGE_IMAGE = FIRStorage.storage().reference().child("post_image")
    let REF_STORAGE_VIDEO = FIRStorage.storage().reference().child("post_video")
    func uploadImageToStorage(imageData: Data, thumbnailData: Data, onSuccess: @escaping (Dictionary<String, String>) -> Void, onError: @escaping (Error?) -> Void) {
        let imageId = UUID().uuidString
        let thumbnailId = UUID().uuidString
        var dict: Dictionary<String,String> = ["imageUrl":"", "thumbnailUrl":""]
        REF_STORAGE_IMAGE.child(imageId).put(imageData, metadata: nil) { (imageMeta, imageError) in
            if imageError != nil {
                onError(imageError)
            }else {
                self.REF_STORAGE_IMAGE.child(thumbnailId).put(thumbnailData, metadata: nil, completion: { (thumbnailMeta, thumbnailError) in
                    if thumbnailError != nil {
                        onError(thumbnailError)
                    }else {
                        if let imageUrl = imageMeta?.downloadURL()?.absoluteString, let thumbnailUrl = thumbnailMeta?.downloadURL()?.absoluteString {
                            dict["imageUrl"] = imageUrl
                            dict["thumbnailUrl"] = thumbnailUrl
                            onSuccess(dict)
                        }
                    }
                })
            }
        }
    }
    func uploadVideoToStorage(url: URL, onSuccess: @escaping (String) -> Void, onError: @escaping (Error?) -> Void) {
        let videoId = UUID().uuidString
        REF_STORAGE_VIDEO.child(videoId).putFile(url, metadata: nil) { (meta, error) in
            if error != nil {
                onError(error)
            }else {
                if let url = meta?.downloadURL()?.absoluteString {
                    onSuccess(url)
                }
            }
        }
    }
}
