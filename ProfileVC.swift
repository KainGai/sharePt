import UIKit
class ProfileVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var popUpView: PopUpView!
    @IBOutlet weak var darkView: UIView!
    var user: User!
    var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        loadUser()
        loadPosts()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        collectionView.addGestureRecognizer(longPress)
    }
    func loadUser() {
        Api.USER.observeCurrentUser { (user) in
            self.user = user
            self.collectionView.reloadData()
        }
    }
    func loadPosts() {
        Api.USER.observeCurrentUserId { (uid) in
            Api.USER_POST.observeUserPost(uid: uid) { (snapshot) in
                Api.POST.observeSinglePost(postId: snapshot.key, completion: { (post) in
                    self.posts.append(post)
                    self.collectionView.reloadData()
                })
            }
        }
    }
}
extension ProfileVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath) as? ProfileCell{
            cell.post = posts[indexPath.row]
            return cell
        }else {
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeader", for: indexPath) as? ProfileHeaderReusableView {
            if let user = self.user {
                headerCell.user = user
                headerCell.settingDelegate = self
            }
            return headerCell
        }else {
            return UICollectionReusableView()
        }
    }
}
extension ProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
}
extension ProfileVC: ProfileHeaderReusableViewSettingDelegate {
    func switchToSettingVC() {
        performSegue(withIdentifier: "Profile_Setting_Segue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_Setting_Segue" {
            let navi = segue.destination as! UINavigationController
            let destination = navi.topViewController as! SettingVC
            destination.delegate = self
        }else if segue.identifier == "Profile_Detail_Segue" {
            if let destination = segue.destination as? DetailVC {
                destination.post = (sender as? Post)!
            }
        }
    }
}
extension ProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Profile_Detail_Segue", sender: posts[indexPath.row])
    }
}
extension ProfileVC: SettingDelegate {
    func updateUserInfo() {
        self.loadUser()
    }
}
extension ProfileVC: UIGestureRecognizerDelegate {
    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let position = gestureRecognizer.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: position) {
                popUpView.post = posts[indexPath.row]
                popUpView.center = view.center
                popUpView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
                view.addSubview(popUpView)
                UIView.animate(withDuration: 0.5, animations: {
                    self.darkView.alpha = 0.8
                })
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
                    self.popUpView.transform = .identity
                })
            }
        }else if gestureRecognizer.state == UIGestureRecognizerState.ended {
            popUpView.removeFromSuperview()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            })
        }
    }
}
