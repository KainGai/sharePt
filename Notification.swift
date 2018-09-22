import Foundation
class Notification {
    var ID: String?
    var from: String?
    var objectID: String?
    var type: String?
    var timestamp: Int?
    static func convertNotification(dict: [String : AnyObject], key: String) -> Notification {
        let notification = Notification()
        notification.ID = key
        notification.from = dict["from"] as? String
        notification.objectID = dict["objectID"] as? String
        notification.type = dict["type"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        return notification
    }
}
