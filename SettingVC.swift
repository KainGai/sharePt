import UIKit
import ProgressHUD
protocol SettingDelegate {
    func updateUserInfo()
}
class SettingVC: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var infoTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var changePhotoButton: UIButton!
    var imagePicker: UIImagePickerController!
    var delegate: SettingDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        changePhotoButton.backgroundColor = UIColor.white
        changePhotoButton.setTitleColor(.black, for: .normal)
        changePhotoButton.layer.borderWidth = 1
        changePhotoButton.layer.borderColor = UIColor.black.cgColor
        infoTextField.delegate = self
        usernameTextfield.delegate = self
        disableSaveButton()
        handleTextField()
        setupUser()
    }
    func setupUser() {
        Api.USER.observeCurrentUser { (user) in
            self.profileImageView.sd_setImage(with: URL(string: user.profileImageUrl!))
            self.usernameTextfield.text = user.username
            self.infoTextField.text = user.info
        }
    }
    @IBAction func savePressed(_ sender: Any) {
        infoTextField.resignFirstResponder()
        usernameTextfield.resignFirstResponder()
        ProgressHUD.show("Saving...")
        if let profileImg = profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            Helper.shared.updateUser(username: usernameTextfield.text!, image: imageData, info: infoTextField.text!, onSuccess: { 
                self.delegate?.updateUserInfo()
                ProgressHUD.showSuccess("Saved", interaction: false)
                self.disableSaveButton()
            }, onError: { error in
                ProgressHUD.showError(error, interaction: false)
            })
        }
    }
    @IBAction func changePhotoPressed(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func logOutPressed(_ sender: Any) {
        Helper.shared.logOut {
            let storyBoard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyBoard.instantiateViewController(withIdentifier: "SignInVC")
            self.present(signInVC, animated: true, completion: nil)
        }
    }
}
extension SettingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) { 
            if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                self.profileImageView.image = image
                self.enableSaveButton()
            }
        }
    }
}
extension SettingVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func handleTextField() {
        infoTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        usernameTextfield.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    func textFieldDidChange() {
        if (usernameTextfield.text == "") {
            disableSaveButton()
            return
        }
        enableSaveButton()
    }
    func enableSaveButton() {
        saveButton.isEnabled = true
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
    }
    func disableSaveButton() {
        saveButton.isEnabled = false
        saveButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
    }
}
