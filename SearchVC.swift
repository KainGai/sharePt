import UIKit
class SearchVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var searchBar: UISearchBar!
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = 80
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame.size.width = view.frame.size.width - 60
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        let barItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = barItem
        doSearch()
    }
    func doSearch() {
        if let searchText = searchBar.text?.lowercased() {
            users.removeAll()
            tableView.reloadData()
            Api.USER.queryUser(text: searchText, completion: { (user) in
                self.checkIfFollowing(uid: user.uid!, completion: { (value) in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            })
        }
    }
    func checkIfFollowing(uid: String, completion: @escaping (Bool) -> Void) {
        Api.FOLLOW.checkFollowing(uid: uid) { (value) in
            completion(value)
        }
    }
}
extension SearchVC: UISearchBarDelegate, UITableViewDataSource {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        doSearch()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as? SearchCell {
            cell.user = users[indexPath.row]
            cell.delegate = self
            return cell
        }else {
            return UITableViewCell()
        }
    }
}
extension SearchVC: SearchCellDelegate {
    func switchToProfile(uid: String) {
        performSegue(withIdentifier: "Search_OtherProfile_Segue", sender: uid)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search_OtherProfile_Segue" {
            let destination = segue.destination as? OtherProfileVC
            destination?.uid = sender as? String
            destination?.delegate = self
        }
    }
}
extension SearchVC: ProfileHeaderReusableViewDelegate {
    func updateFollowButtonInfo(user: User) {
        users.forEach { (u) in
            if u.uid == user.uid {
                u.isFollowing = user.isFollowing
                tableView.reloadData()
            }
        }
    }
}
