import UIKit
protocol ProfileHeaderReusableViewDelegate {
    func updateFollowButtonInfo(user: User)
}
protocol ProfileHeaderReusableViewSettingDelegate {
    func switchToSettingVC()
}
class ProfileHeaderReusableView: UICollectionReusableView {
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userCaptionLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    var delegate: ProfileHeaderReusableViewDelegate?
    var settingDelegate: ProfileHeaderReusableViewSettingDelegate?
    var user: User? {
        didSet{
            configureHeader(user: user!)
            updatePostCount()
            updateFollowerCount()
            updateFollowingCount()
        }
    }
    func configureHeader(user: User) {
        if let url = user.profileImageUrl {
            profileImgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeholderImg"))
            usernameLabel.text = user.username
            userCaptionLabel.text = user.info
        }
        if user.uid == Api.USER.CURRENT_USER?.uid {
            updateEditButton()
        }else {
            updateFollowButton()
        }
    }
    func updateEditButton() {
        editButton.setTitle("Edit Profile", for: .normal)
        editButton.backgroundColor = UIColor.white
        editButton.setTitleColor(.black, for: .normal)
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.black.cgColor
        editButton.addTarget(self, action: #selector(self.goToSettingVC), for: .touchUpInside)
    }
    func updateFollowButton() {
        if user!.isFollowing! {
            configureUnfollowButton()
        }else {
            configureFollowButton()
        }
    }
    func configureFollowButton() {
        editButton.setTitle("Follow", for: .normal)
        editButton.backgroundColor = UIColor.white
        editButton.setTitleColor(.black, for: .normal)
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.addTarget(self, action: #selector(self.follow), for: .touchUpInside)
    }
    func configureUnfollowButton() {
        editButton.setTitle("Following", for: .normal)
        editButton.backgroundColor = UIColor.black
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.addTarget(self, action: #selector(self.unfollow), for: .touchUpInside)
    }
    func follow() {
        Api.FOLLOW.followAction(uid: user!.uid!)
        user?.isFollowing = true
        delegate?.updateFollowButtonInfo(user: user!)
        editButton.removeTarget(self, action: #selector(self.follow), for: .touchUpInside)
        configureUnfollowButton()
    }
    func unfollow() {
        Api.FOLLOW.unFollowAction(uid: user!.uid!)
        user?.isFollowing = false
        delegate?.updateFollowButtonInfo(user: user!)
        editButton.removeTarget(self, action: #selector(self.unfollow), for: .touchUpInside)
        configureFollowButton()
    }
    func updatePostCount() {
        Api.USER_POST.observeUserPostCount(uid: user!.uid!) { (count) in
            self.postCountLabel.text = "\(count)"
        }
    }
    func updateFollowerCount() {
        Api.FOLLOW.observeFollowerCount(uid: user!.uid!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
    }
    func updateFollowingCount() {
        Api.FOLLOW.observeFollowingCount(uid: user!.uid!) { (count) in
            self.followingCountLabel.text = "\(count)"
        }
    }
    func goToSettingVC() {
        settingDelegate?.switchToSettingVC()
    }
}
