import UIKit
class ProfileImageView: UIImageView, Jitterable {
    override func awakeFromNib() {
        self.layer.cornerRadius = self.bounds.size.width / 2
    }
}
