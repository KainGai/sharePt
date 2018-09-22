import UIKit
class DiscoverVC: UIViewController {
    @IBOutlet weak var darkView: UIView!
    @IBOutlet var popUpView: PopUpView!
    @IBOutlet weak var collectionView: UICollectionView!
    var posts = [Post]()
    var blockList = [String]()
    var refreshControl: UIRefreshControl!
	var pagination = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching new posts......", attributes: [NSForegroundColorAttributeName:UIColor.black])
        refreshControl.addTarget(self, action: #selector(self.loadPosts), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        loadBlockList {
            self.loadPosts()
            self.removeBlockFeed()
            self.addUnblockFeed()
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        collectionView.addGestureRecognizer(longPress)
    }
    func loadPosts() {
        posts.removeAll()
		pagination = 20
		Api.POST.observeTopPosts(pagination: pagination, shouldLoadMore: false) { (post) in
			self.posts.insert(post, at: 0)
			self.collectionView.reloadData()
			self.refreshControl.endRefreshing()
		}
    }
	func loadMorePosts() {
		if(pagination <= posts.count) {
			pagination += 10
			let postCount = posts.count
			Api.POST.observeTopPosts(pagination: pagination, shouldLoadMore: true, postCount: postCount, completion: { (post) in
				self.posts.append(post)
				self.collectionView.reloadData()
				self.refreshControl.endRefreshing()
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
            self.blockList.append(id)
            self.collectionView.reloadData()
        }
    }
    func addUnblockFeed() {
        guard let currentUserUID = Api.USER.CURRENT_USER?.uid else {return}
        Api.USER_BLOCK.observeUnblock(uid: currentUserUID) { (id) in
            self.blockList.remove(at: self.blockList.index(of: id)!)
            Api.USER_POST.observeUserPostSingleEvent(uid: id, completion: { (postID) in
                Api.POST.observeSinglePost(postId: postID, completion: { (post) in
                    self.posts.append(post)
                    self.collectionView.reloadData()
                })
            })
        }
    }
}
extension DiscoverVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverCell", for: indexPath) as? DiscoverCell {
            if !refreshControl.isRefreshing {
                cell.post = posts[indexPath.row]
            }
            return cell
        }else {
            return UICollectionViewCell()
        }
    }
}
extension DiscoverVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
extension DiscoverVC: UICollectionViewDelegate {
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		loadMorePosts()
	}
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Discover_Detail_Segue", sender: posts[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Discover_Detail_Segue" {
            if let destination = segue.destination as? DetailVC {
                destination.post = (sender as? Post)!
            }
        }
    }
}
extension DiscoverVC: UIGestureRecognizerDelegate {
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
