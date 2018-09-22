import UIKit
class HashTagVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var posts = [Post]()
    var hashTag: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "#\(hashTag!)"
        collectionView.dataSource = self
        collectionView.delegate = self
        loadPosts()
    }
    func loadPosts() {
        Api.HASHTAG.retrievePostID(hashTag: hashTag!) { (postId) in
            Api.POST.observeSinglePost(postId: postId, completion: { (post) in
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
}
extension HashTagVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HashTagCell", for: indexPath) as? DiscoverCell {
            cell.post = posts[indexPath.row]            
            return cell
        }else {
            return UICollectionViewCell()
        }
    }
}
extension HashTagVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 1, height: collectionView.frame.size.width / 3 - 1)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "HashTag_Detail_Segue", sender: posts[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "HashTag_Detail_Segue") {
            if let destination = segue.destination as? DetailVC {
                destination.post = sender as? Post
            }
        }
    }
}
