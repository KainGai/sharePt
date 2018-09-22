import UIKit
import ProgressHUD
class SignInVC: UIViewController {
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var signInButton: CustomButtons!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 2.5) {
            self.emailTextField.alpha = 0.7
            self.passwordTextField.alpha = 0.7
            self.signInButton.alpha = 0.7
            self.passwordButton.alpha = 1
            self.signUpButton.alpha = 1
            self.logoLabel.alpha = 1
        }
        signInButton.isEnabled = false
        handleTextField()
        hideKeyboardWhenTappedAround()
    }
    override func viewDidAppear(_ animated: Bool) {
        Api.USER.userStateChangeListener { (user) in
            if user != nil {
                Helper.shared.switchViewToHome(identifier: "signInToTabVC", view: self)
            }
        }
    }
    @IBAction func signInPressed(_ sender: Any) {
        dismissKeyboard()
        ProgressHUD.show("Signing in...", interaction: false)
        Helper.shared.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSucess: {
            ProgressHUD.showSuccess()
            Helper.shared.switchViewToHome(identifier: "signInToTabVC", view: self)
        }, onError: {error in
            ProgressHUD.showError(error, interaction: false)
        })
    }
    @IBAction func passwordButtonPressed(_ sender: Any) {
        let vc = ResetPasswordVC()
        present(vc, animated: true)
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension SignInVC {
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(SignInVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignInVC.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    func textFieldDidChange() {
        if (emailTextField.text! == "" || passwordTextField.text! == "") {
            signInButton.alpha = 0.7
            signInButton.setTitleColor(UIColor.lightText, for: .normal)
            signInButton.isEnabled = false
            return
        }
        signInButton.alpha = 1
        signInButton.setTitleColor(UIColor.white, for: .normal)
        signInButton.isEnabled = true
    }
}
