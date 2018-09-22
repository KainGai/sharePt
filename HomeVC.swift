import UIKit
import SDWebImage
import AVFoundation
import Fusuma
protocol PassPhotoDelegate {
    func passImage(with image: UIImage)
}
class HomeVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var filterVC: FilterVC?
    lazy var fusumaCamera: FusumaViewController = {
        let picker = FusumaViewController()
        picker.delegate = self
        return picker
    }()
    var fusumaNavigation: UINavigationController?
    var posts = [Post]()
    var users = [User]()
	var pagination = 3
    var blockList = [String]()
    var player: AVPlayer?
	var refreshControl: UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 520
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
		refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		if #available(iOS 10.0, *) {
			tableView.refreshControl = refreshControl
		} else {
			tableView.addSubview(refreshControl)
		}
        loadBlockList(completion: {
            self.loadPost()
            self.removeBlockFeed()
            self.addUnblockFeed()
        })
        tabBarController?.delegate = self
        filterVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: "FilterSB") as? FilterVC
    }
	func refresh() {
		posts.removeAll()
		users.removeAll()
		pagination = 3
		loadPost()
	}
    func loadPost() {
        activityIndicator.startAnimating()
        guard let currentUserUID = Api.USER.CURRENT_USER?.uid else {return}
        Api.FEED.observeFeed(uid: currentUserUID, completion: { (post) in
            if(!self.blockList.contains(post.uid!)) {
                self.loadUser(uid: post.uid!, completed: {(user) in
                    self.posts.insert(post, at: 0)
                    self.users.insert(user, at: 0)
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                })
            }
        })
        Api.FEED.observeFeedRemoved(uid: currentUserUID, completion: { (post) in
            self.posts = self.posts.filter{$0.postId != post.postId}
            self.users = self.users.filter{$0.uid != post.uid}
            self.tableView.reloadData()
			self.refreshControl.endRefreshing()
        })
    }
    func loadUser(uid: String, completed: @escaping(User) -> Void) {
        Api.USER.observeUsers(uid: uid) { (user) in
            completed(user)
        }
    }
	func loadMorePosts() {
		guard let currentUserUID = Api.USER.CURRENT_USER?.uid else {return}
		if(pagination <= posts.count) {
			activityIndicator.startAnimating()
			pagination += 2
			let postCount = posts.count
			Api.FEED.observeFeed(withUID: currentUserUID, pagination: pagination, shouldLoadMore: true, postCount: postCount, completion: { (post, user) in
				self.posts.append(post)
				self.users.append(user)
				self.tableView.reloadData()
				self.activityIndicator.stopAnimating()
			}, isHiddenIndicator: { (bool) in
				if let _ = bool {
					if(bool == true) {
						self.activityIndicator.stopAnimating()
					}
				}
			})
		}
	}
    func loadBlockList(completion: @escaping () -> Void) {
        guard let uid = Api.USER.CURRENT_USER?.uid else {return}
        Api.USER_BLOCK.observeBlockList(uid: uid, completion: { (id) in
            self.blockList.append(id)
        })
        completion()
    }
    func removeBlockFeed() {
        guard let currentUserUID = Api.USER.CURRENT_USER?.uid else {return}
        Api.USER_BLOCK.observeBlock(uid: currentUserUID) { (id) in
            self.posts = self.posts.filter{$0.uid != id}
            self.users = self.users.filter{$0.uid != id}
            self.tableView.reloadData()
        }
    }
    func addUnblockFeed() {
        guard let currentUserUID = Api.USER.CURRENT_USER?.uid else {return}
        Api.USER_BLOCK.observeUnblock(uid: currentUserUID) { (id) in
            Api.USER_POST.observeUserPostSingleEvent(uid: id, completion: { (postID) in
                Api.POST.observeSinglePost(postId: postID, completion: { (post) in
                    self.loadUser(uid: post.uid!, completed: {(user) in
                        self.users.insert(user, at: 0)
                        self.posts.insert(post, at: 0)
                        self.tableView.reloadData()
                    })
                })
            })
        }
    }
}
extension HomeVC: UITabBarControllerDelegate, FusumaDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {        
        guard let nav = viewController as? UINavigationController else {return true}
        if(nav.viewControllers.first is CameraVC) {
            presentImagePicker()
            return false
        }
        return true
    }
    func presentImagePicker() {
        fusumaCamera.nextVC = filterVC
        fusumaNavigation = UINavigationController(rootViewController: fusumaCamera)
        fusumaNavigation?.navigationBar.tintColor = .black
        present(fusumaNavigation!, animated: true)
    }
    func fusumaImageSelected(_ image: UIImage) {
        filterVC?.selectedImage = image
        fusumaNavigation?.setNavigationBarHidden(false, animated: false)
    }
    func fusumaDismissedWithImage(_ image: UIImage) {}
    func fusumaCameraRollUnauthorized() {
        let alert = UIAlertController(title: "No Photo Access Permission", message: "Please grant access in Setting -> Privacy", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: ["":""])
                } else {
                    UIApplication.shared.openURL(url)
                }
                return
            }
        }))
        present(alert, animated: true)
    }
    func fusumaVideoCompleted(withFileURL fileURL: URL) {}
}
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
			if(!refreshControl.isRefreshing) {
				cell.post = posts[indexPath.row]
				cell.user = users[indexPath.row]
				cell.delegate = self
				player = cell.AVplayer
			}
            return cell
        }else {
            return UITableViewCell()
        }
    }
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		loadMorePosts()
	}
}
extension HomeVC: PostCellDelegate {
    func switchToCommentVC(postId: String) {
        performSegue(withIdentifier: "toCommentVC", sender: postId)
    }
    func switchToProfile(uid: String) {
        performSegue(withIdentifier: "Home_OtherProfile_Segue", sender: uid)
    }
    func switchToHashTagVC(tag: String) {
        performSegue(withIdentifier: "Home_HashTag_Segue", sender: tag)
    }
    func reportOffensive(postID: String) {
        Helper.shared.reportPost(postID: postID, VC: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentVC" {
            if let destination = segue.destination as? CommentVC {
                destination.postId = sender as? String
            }
        }else if segue.identifier == "Home_OtherProfile_Segue" {
            if let destination = segue.destination as? OtherProfileVC {
                destination.uid = sender as? String
            }
        }else if segue.identifier == "Home_HashTag_Segue" {
            if let destination = segue.destination as? HashTagVC {
                destination.hashTag = sender as? String
            }
        }
    }
}
extension HomeVC: SettingDelegate {
    func updateUserInfo() {
    }
}
