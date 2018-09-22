import UIKit
@IBDesignable class PopUpView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    override func awakeFromNib() {
        bounds.size.width = UIScreen.main.bounds.width * 0.9
        bounds.size.height = UIScreen.main.bounds.width * 0.9
    }
    var post: Post? {
        didSet{
            configureView()
        }
    }
    func configureView() {
        if let urlString = post?.photoUrl, let url = URL(string: urlString) {
            imageView.setShowActivityIndicator(true)
            imageView.setIndicatorStyle(.gray)
            imageView.sd_setImage(with: url)
        }
    }
}
