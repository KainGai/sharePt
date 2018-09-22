import UIKit
class PolicyVC: UIViewController {
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        textView.contentOffset = .zero
    }
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
