import Foundation
import FirebaseAuth
import UIKit
import FirebaseStorage
import FirebaseDatabase
import ProgressHUD
class Helper {
    static let shared = Helper()
    let adminUID = "QyIdW0b0izarKBcZeyUGEsu8U0b2"
    func switchViewToHome(identifier: String, view: UIViewController) {
        view.performSegue(withIdentifier: identifier, sender: nil)
    }
    func signIn(email: String, password: String, onSucess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                onError(error?.localizedDescription)
                return
            }
            onSucess()
        })
    }
    func signUp(username: String, email: String, password: String, image: Data, onSucess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void){
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                onError(error?.localizedDescription)
            }else {
                let newUserRef = FIRDatabase.database().reference().child("users").child((user?.uid)!)
                let newUserProfileImageRef = FIRStorage.storage().reference().child("profile_image").child((user?.uid)!)
                newUserProfileImageRef.put(image, metadata: nil, completion: { (meta, error) in
                    if error != nil {
                        onError(error?.localizedDescription)
                    }else {
                        let imgURL = meta?.downloadURL()?.absoluteString
                        newUserRef.setValue(["email" : email, "username" : username, "username_lowercase" : username.lowercased(), "profileImageURL" : imgURL, "info" : "Hi, Poto!"])
                        self.followAdmin(adminUID: self.adminUID, userUID: (user?.uid)!)
                        onSucess()
                    }
                })
            }
        })
    }
    func followAdmin(adminUID: String, userUID: String) {
        Api.FOLLOW.REF_FOLLOWER.child(adminUID).child(userUID).setValue(true)
        Api.FOLLOW.REF_FOLLOWING.child(userUID).child(adminUID).setValue(true)
        Api.USER_POST.REF_USER_POST.child(adminUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                for key in dict.keys {
                    Api.POST.observeSinglePost(postId: key, completion: { (post) in
                        Api.FEED.saveNewFeed(uid: userUID, postId: key, timestamp: post.timestamp!)
                    })                    
                }
            }
        })
    }
    func updateUser(username: String, image: Data, info: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String?) -> Void) {
        let newUserProfileImageRef = FIRStorage.storage().reference().child("profile_image").child((Api.USER.CURRENT_USER?.uid)!)
        newUserProfileImageRef.put(image, metadata: nil) { (meta, error) in
            if error != nil {
                onError(error?.localizedDescription)
            }else {
                let url = meta?.downloadURL()?.absoluteString
                self.updateDatabase(imgURL: url!, username: username, info: info, onSuccess: onSuccess, onError: onError)
            }
        }
    }
    func updateDatabase(imgURL: String, username: String, info: String, onSuccess: @escaping () -> Void, onError: @escaping (_ : String?) -> Void) {
        let dict = ["username" : username, "username_lowercase" : username.lowercased(), "profileImageURL" : imgURL, "info" : info]
        Api.USER.REF_USERS.child((Api.USER.CURRENT_USER?.uid)!).updateChildValues(dict) { (error, ref) in
            if error != nil {
                onError(error?.localizedDescription)
            }else {
                onSuccess()
            }
        }
    }
    func reportPost(postID: String, VC: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report as offensive", style: .destructive) { (action) in
            Api.POST_REPORT.observeSingleReport(postID: postID, completion: { (exist) in
                if(exist) {
                    Api.POST_REPORT.increaseReportCount(postID: postID, success: { 
                        ProgressHUD.showSuccess("Report submitted.", interaction: false)
                    }, fail: { 
                        ProgressHUD.showError("Report fail. Please try again later.", interaction: false)
                    })
                }else {
                    Api.POST_REPORT.createReport(postID: postID, success: { 
                        ProgressHUD.showSuccess("Report submitted.", interaction: false)
                    }, fail: { 
                        ProgressHUD.showError("Report fail. Please try again later.", interaction: false)
                    })
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        VC.present(alertController, animated: true)
    }
    func blockUser(uid: String, VC: UIViewController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let blockAction = UIAlertAction(title: "Block User", style: .destructive) { (action) in
            Api.USER_BLOCK.blockUser(targetUID: uid)
            self.displayAlert(title: "User Blocked", message: "You won't see their posts in your Home Feed or Discover. They won't know that you've blocked them.", VC: VC)
        }
        let unblockUser = UIAlertAction(title: "Unblock User", style: .default) { (action) in
            Api.USER_BLOCK.unblockUser(targetUID: uid)
            self.displayAlert(title: "User Unblocked", message: "You will see their posts in your Home Feed or Discover. They won't know that you've unblocked them.", VC: VC)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        Api.USER_BLOCK.checkIfBlocked(targetUID: uid) { (blocked) in
            if(blocked) {
                alertController.addAction(unblockUser)
            }else {
                alertController.addAction(blockAction)
            }
            VC.present(alertController, animated: true)
        }
    }
    func displayAlert(title: String, message: String, VC: UIViewController) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        controller.addAction(okAction)
        VC.present(controller, animated: true)
    }
    func resetPasswordByEmail(withEmail: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: withEmail, completion: { (error) in
            if(error != nil) {
                onError(error!.localizedDescription)
            }else {
                onSuccess()
            }
        })
    }
    func logOut(completion: @escaping () -> Void) {
        do{
            try FIRAuth.auth()?.signOut()
            completion()
        }catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
extension UIImage {
    public func rotateImageByDegrees(deg degrees: CGFloat) -> UIImage {
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    public func resizeUIImage(toWidth: CGFloat) -> UIImage {
        let ratio = self.size.width / toWidth
        UIGraphicsBeginImageContext(CGSize(width: toWidth, height: self.size.height / ratio))
        self.draw(in: CGRect(x: 0, y: 0, width: toWidth, height: self.size.height / ratio))
        if let newImage = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            return newImage
        }
        return UIImage()
    }
}
protocol Jitterable {}
extension Jitterable where Self: UIView {
    func Jitter() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        layer.add(animation, forKey: "position")
    }
}
