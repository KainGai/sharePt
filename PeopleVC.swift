import UIKit
class PeopleVC: UITableViewController {
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        loadUsers()
    }
    func loadUsers() {
        Api.USER.observeAllUsers { (user) in
            self.checkIfFollowing(uid: user.uid!, completion: { (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    func checkIfFollowing(uid: String, completion: @escaping (Bool) -> Void) {
        Api.FOLLOW.checkFollowing(uid: uid) { (value) in
            completion(value)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileSegue" {
            if let otherProfileVC = segue.destination as? OtherProfileVC {
                otherProfileVC.uid = sender as? String
                otherProfileVC.delegate = self
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as? PeopleCell {
            cell.user = users[indexPath.row]
            cell.delegate = self
            return cell
        }else {
            return UITableViewCell()
        }
    }
}
extension PeopleVC: PeopleCellDelegate {
    func switchToProfile(uid: String) {
        performSegue(withIdentifier: "ProfileSegue", sender: uid)
    }
}
extension PeopleVC: ProfileHeaderReusableViewDelegate {
    func updateFollowButtonInfo(user: User) {
        users.forEach { (u) in
            if u.uid == user.uid {
                u.isFollowing = user.isFollowing
                tableView.reloadData()
            }
        }
    }
}
