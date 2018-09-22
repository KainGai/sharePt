import UIKit
class FilterCell: UICollectionViewCell {
    @IBOutlet weak var filterImage: UIImageView!
    var selectedImage: UIImage? {
        didSet{
            configureFilter(image: selectedImage!)
        }
    }
    func configureFilter(image: UIImage) {
        filterImage.image = image
    }
}
