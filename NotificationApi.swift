import Foundation
import FirebaseDatabase
class NotificationApi {
    let REF_NOTIFICATION = FIRDatabase.database().reference().child("notification")
    func sendNotification(from: String, type: String, objectID: String, timestamp: Int) {
        Api.FOLLOW.REF_FOLLOWER.child(from).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotArray = snapshot.children.allObjects as? [FIRDataSnapshot] {
                snapshotArray.forEach({ (child) in
                    self.REF_NOTIFICATION.child(child.key).childByAutoId().setValue(["from" : from, "type" : type, "objectID" : objectID, "timestamp" : timestamp], withCompletionBlock: { (error, ref) in
                        if(error != nil) {
                            print(error!.localizedDescription)
                            return
                        }
                    })                
                })
            }            
        })
    }
    func observeNotifications(uid: String, completion: @escaping (Notification) -> Void) {
        REF_NOTIFICATION.child(uid).observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String : AnyObject] {
                let notification = Notification.convertNotification(dict: dict, key: snapshot.key)
                completion(notification)
            }
        })
    }
}
