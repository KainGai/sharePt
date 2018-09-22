import UIKit
class ProfileCell: UICollectionViewCell {
    @IBOutlet weak var profileCellImg: UIImageView!
    var post: Post? {
        didSet{
            configureCell()
        }
    }
    func configureCell() {
        if let urlString = post!.thumbnailUrl, let url = URL(string: urlString) {
            profileCellImg.sd_setImage(with: url)
        }
    }
}
