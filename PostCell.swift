import UIKit
import AVFoundation
import KILabel
protocol PostCellDelegate {
    func switchToCommentVC(postId: String)
    func switchToProfile(uid: String)
    func switchToHashTagVC(tag: String)
    func reportOffensive(postID: String)
}
class PostCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var dotsImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var volumnView: UIView!
    @IBOutlet weak var volumnButton: UIButton!
    @IBOutlet weak var postTimeLabel: UILabel!
    var AVplayer: AVPlayer?
    var AVplayerLayer: AVPlayerLayer?
    var isMuted = true
    var likeRefHandler: UInt?
    var delegate: PostCellDelegate?
    var post: Post? {
        didSet{
            configureCell(post: post!)
        }
    }
    var user: User? {
        didSet{
            setUpUserInfo(user: user!)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.text = ""
        captionLabel.text = ""
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        shareImageView.alpha = 0
        commentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleCommentButton)))
        likeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.likeButtonPressed)))
        dotsImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDotsPressed)))
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.detailProfilePressed)))
        usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.detailProfilePressed)))
        dotsImageView.isUserInteractionEnabled = true
        profileImageView.isUserInteractionEnabled = true
        usernameLabel.isUserInteractionEnabled = true
    }
    func configureCell(post: Post) {
        captionLabel.text = post.caption
        captionLabel.hashtagLinkTapHandler = {label, hashtag, range in
            let tag = String(hashtag.characters.dropFirst())
            self.delegate?.switchToHashTagVC(tag: tag)
        }
        captionLabel.userHandleLinkTapHandler = {label, username, range in
            let name = String(username.characters.dropFirst())
            Api.USER.retrieveUserByUserName(username: name, onSuccess: { (user) in
                self.delegate?.switchToProfile(uid: user.uid!)
            })
        }
        configureLikes(post: self.post!)
        configureTimestamp(post: self.post!)
        if let postImageUrlString = post.photoUrl, let url = URL(string: postImageUrlString) {
            postImageView.setShowActivityIndicator(true)
            postImageView.setIndicatorStyle(.gray)
            postImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Placeholder-image"))
        }
        if let postVideoUrlString = post.videoUrl, let url = URL(string: postVideoUrlString) {
            volumnView.isHidden = false
            volumnView.layer.zPosition = 1
            AVplayer = AVPlayer(url: url)
            AVplayerLayer = AVPlayerLayer(player: AVplayer)
            AVplayerLayer?.frame = postImageView.frame
            AVplayerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill 
            self.contentView.layer.addSublayer(AVplayerLayer!)
            AVplayer?.play()
            AVplayer?.isMuted = isMuted
        }
    }
    func setUpUserInfo(user: User) {
        if let profileImageUrlString = user.profileImageUrl {
            profileImageView.sd_setImage(with: URL(string: profileImageUrlString), placeholderImage: #imageLiteral(resourceName: "placeholderImg"))
        usernameLabel.text = user.username
        }
        if let post = self.post, let user = self.user {
            if(post.caption != "") {
                let attribute = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 13)]
                let bold = NSMutableAttributedString(string: user.username! + " ",attributes: attribute)
                let normal = NSMutableAttributedString(string: post.caption!)
                bold.append(normal)
                captionLabel.attributedText = bold
            }
        }
    }
    func configureLikes(post: Post) {
        let image = post.likes == nil || !post.isLiked! ? #imageLiteral(resourceName: "like_new") : #imageLiteral(resourceName: "like_selected_new")
        self.likeImageView.image = image
        if let count = post.likeCount, count != 0 {
            self.likeCountButton.setTitle("\(count) likes", for: .normal)
        }else {
            self.likeCountButton.setTitle("Be the first to like", for: .normal)
        }
    }
    func configureTimestamp(post: Post) {
        if let timestamp = post.timestamp {
            let timestampDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second,.minute,.hour,.day,.weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            var timestampText = ""
            if(diff.second! <= 0 && diff.minute! == 0) {
                timestampText = "Now"
            }
            if(diff.second! > 0 && diff.minute! == 0) {
                timestampText = (diff.second! == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if(diff.minute! > 0 && diff.hour! == 0) {
                timestampText = (diff.minute! == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if(diff.hour! > 0 && diff.day! == 0) {
                timestampText = (diff.hour! == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if(diff.day! > 0 && diff.weekOfMonth! == 0) {
                timestampText = (diff.day! == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if(diff.weekOfMonth! > 0) {
                timestampText = (diff.weekOfMonth! == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            postTimeLabel.text = timestampText
        }
    }
    func likeButtonPressed() {
        if(likeImageView.image == #imageLiteral(resourceName: "like_new")) {
            likeImageView.image = #imageLiteral(resourceName: "like_selected_new")
            UIView.animate(withDuration: 0.2, animations: { 
                self.likeImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }, completion: { (completed) in
                if(completed) {
                    UIView.animate(withDuration: 0.2, animations: { 
                        self.likeImageView.transform = .identity
                    })
                }
            })
        }else {
            likeImageView.image = #imageLiteral(resourceName: "like_new")
        }
        Api.POST.increaseLikes(postId: self.post!.postId!, onSuccess: {
            Api.POST.observeSinglePost(postId: self.post!.postId!) { (_post) in
                self.configureLikes(post: _post)
                self.post!.likes = _post.likes
                self.post!.isLiked = _post.isLiked
                self.post!.likeCount = _post.likeCount
            }
        }) { (error) in
            print(error!)
        }
    }
    func handleCommentButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.commentImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (completed) in
            UIView.animate(withDuration: 0.1, animations: { 
                self.commentImageView.transform = .identity
            }, completion: { (Bool) in
                if let id = self.post?.postId {
                    self.delegate?.switchToCommentVC(postId: id)
                }
            })
        }
    }
    func detailProfilePressed() {
        if let uid = post?.uid {
            delegate?.switchToProfile(uid: uid)
        }
    }
    func handleDotsPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.dotsImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (completed) in
            UIView.animate(withDuration: 0.1, animations: {
                self.dotsImageView.transform = .identity
            }, completion: { (Bool) in
                if let id = self.post?.postId {
                    self.delegate?.reportOffensive(postID: id)
                }
            })
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = #imageLiteral(resourceName: "placeholderImg")
        AVplayerLayer?.removeFromSuperlayer()
        AVplayer?.pause()
        volumnView.isHidden = true
    }
    @IBAction func volumnButtonPressed(_ sender: Any) {
        if(isMuted) {
            isMuted = !isMuted
            volumnButton.setImage(#imageLiteral(resourceName: "Icon_Volume"), for: .normal)
        }else {
            isMuted = !isMuted
            volumnButton.setImage(#imageLiteral(resourceName: "Icon_Mute"), for: .normal)
        }
        AVplayer?.isMuted = isMuted
    }
}
