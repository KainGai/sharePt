import Foundation
import FirebaseDatabase
class PostReport {
    let REF_POST_REPORT = FIRDatabase.database().reference().child("post-report")
    func observeSingleReport(postID: String, completion: @escaping (Bool) -> Void) {
        REF_POST_REPORT.child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull{
                completion(false)
            }else {
                completion(true)
            }
        })
    }
    func createReport(postID: String, success: @escaping () -> Void, fail: @escaping () -> Void) {
        REF_POST_REPORT.child(postID).setValue(["reportCount" : 1]) { (error, ref) in
            if(error != nil) {
                fail()
            }else {
                success()
            }
        }
    }
    func increaseReportCount(postID: String, success: @escaping () -> Void, fail: @escaping () -> Void) {
        let ref = REF_POST_REPORT.child(postID)
        ref.runTransactionBlock({ (currentData) -> FIRTransactionResult in
            if var report = currentData.value as? [String : AnyObject], let uid = Api.USER.CURRENT_USER?.uid {
                var reportCount = report["reportCount"] as? Int ?? 0
                reportCount += 1
                report["reportCount"] = reportCount as AnyObject?
                currentData.value = report
                return FIRTransactionResult.success(withValue: currentData)
            }else {
                return FIRTransactionResult.success(withValue: currentData)
            }
        }) { (error, committed, snapshot) in
            if(error != nil) {
                fail()
            }else {
                success()
            }
        }
    }
}
