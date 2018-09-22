import UIKit
class DiscoverCell: UICollectionViewCell {
    @IBOutlet weak var discoverCellImage: UIImageView!
    var post: Post? {
        didSet{
            configureCell()
        }
    }
    func configureCell() {
        if let urlString = post!.thumbnailUrl, let url = URL(string: urlString) {
            discoverCellImage.sd_setImage(with: url)
        }
    }
}
