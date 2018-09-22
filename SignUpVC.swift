import UIKit
import ProgressHUD
class SignUpVC: UIViewController {
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var signUpButton: CustomButtons!
    var selectedProfileImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SignUpVC.presentImagePicker)))
        signUpButton.isEnabled = false
        handleTextField()
        hideKeyboardWhenTappedAround()
    }
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func signUpPressed(_ sender: Any) {
        ProgressHUD.show("Signing up...", interaction: false)
        dismissKeyboard()
        if let profileImg = selectedProfileImage?.resizeUIImage(toWidth: 200), let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            Helper.shared.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, image: imageData, onSucess: {
                ProgressHUD.showSuccess()
                Helper.shared.switchViewToHome(identifier: "signUpToTabVC", view: self)
            }, onError: {error in
                ProgressHUD.showError(error!, interaction: false)
            })
        }else {
            profileImageView.Jitter()
            ProgressHUD.showError("Please select a profile image", interaction: false)
        }
    }
}
extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = image
            selectedProfileImage = image
        }
    }
    func presentImagePicker() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(SignUpVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpVC.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    func textFieldDidChange() {
        if (usernameTextField.text! == "" || emailTextField.text! == "" || passwordTextField.text! == "") {
            signUpButton.alpha = 0.7
            signUpButton.setTitleColor(UIColor.lightText, for: .normal)
            signUpButton.isEnabled = false
            return
        }
        signUpButton.alpha = 1
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.isEnabled = true
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
