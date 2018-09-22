import UIKit
protocol SearchCellDelegate {
    func switchToProfile(uid: String)
}
class SearchCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: CustomButtons!
    var user: User? {
        didSet{
            configureCell()
        }
    }
    var delegate: SearchCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.isUserInteractionEnabled = true
        usernameLabel.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.detailProfilePressed)))
        usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.detailProfilePressed)))
    }
    func configureCell() {        
        if let urlString = user!.profileImageUrl, let url = URL(string: urlString) {
            profileImageView.sd_setImage(with: url)
        }
        usernameLabel.text = user?.username
        handleFollowButton(user: user!)
    }
    func handleFollowButton(user: User) {
        if user.isFollowing! {
            configureUnfollowButton()
        }else {
            configureFollowButton()
        }
    }
    func configureFollowButton() {
        followButton.setTitle("follow", for: .normal)
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.setTitleColor(.black, for: .normal)
        followButton.backgroundColor = UIColor.white
        followButton.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
    }
    func configureUnfollowButton() {
        followButton.setTitle("following", for: .normal)
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = UIColor.black
        followButton.addTarget(self, action: #selector(self.unfollow), for: .touchUpInside)
    }
    func follow() {
        if(!user!.isFollowing!) {
            Api.FOLLOW.followAction(uid: (user?.uid)!)
            user!.isFollowing! = true
            configureUnfollowButton()
        }
    }
    func unfollow() {
        if(user!.isFollowing!) {
            Api.FOLLOW.unFollowAction(uid: (user?.uid)!)
            user!.isFollowing! = false
            configureFollowButton()
        }
    }
    func detailProfilePressed() {
        delegate?.switchToProfile(uid: (user?.uid)!)
    }
}
