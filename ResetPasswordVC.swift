import UIKit
import ProgressHUD
class ResetPasswordVC: UIViewController {
    let menuBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 237/255, green: 245/255, blue: 245/255, alpha: 1)
        return view
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Reset Password"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
        return label
    }()
    let dismissButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let attribute = [NSFontAttributeName : UIFont(name: "Avenir Next", size: 15)!]
        let title = NSAttributedString(string: "Close", attributes: attribute )
        button.setAttributedTitle(title, for: .normal)
        button.tintColor = .black
        return button
    }()
    let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    let emailTextField: CustomTextField = {
        let field = CustomTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.backgroundColor = .black
        field.textColor = .white
        field.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName : UIColor(white: 1, alpha: 0.6)])
        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.alpha = 0.7
        field.layer.cornerRadius = 5
        return field
    }()
    let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.lightText, for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = .black
        button.alpha = 0.7
        button.isEnabled = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 237/255, green: 245/255, blue: 245/255, alpha: 1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        setupView()
        setupTextField()
        resetButton.addTarget(self, action: #selector(resetPressed), for: .touchUpInside)
    }
    func setupView() {
        view.addSubview(menuBar)
        menuBar.addSubview(titleLabel)
        menuBar.addSubview(dismissButton)
        menuBar.addSubview(separator)
        view.addSubview(emailTextField)
        view.addSubview(resetButton)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":menuBar]))
        menuBar.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        menuBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":separator]))
        menuBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(1)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":separator]))
        titleLabel.centerXAnchor.constraint(equalTo: menuBar.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: menuBar.centerYAnchor).isActive = true
        dismissButton.centerYAnchor.constraint(equalTo: menuBar.centerYAnchor).isActive = true
        dismissButton.leadingAnchor.constraint(equalTo: menuBar.leadingAnchor, constant: 10).isActive = true
        dismissButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[v0]-30-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":emailTextField]))
        emailTextField.topAnchor.constraint(equalTo: menuBar.bottomAnchor, constant: 50).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[v0]-30-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":resetButton]))
        resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 25).isActive = true
    }
    func dismissView() {
        dismiss(animated: true)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    func setupTextField() {
        emailTextField.addTarget(self, action: #selector(handleResetButton), for: .editingChanged)
    }
    func handleResetButton() {
        if(emailTextField.text! == "") {
            resetButton.alpha = 0.7
            resetButton.setTitleColor(.lightText, for: .normal)
            resetButton.isEnabled = false
        }else {
            resetButton.alpha = 1
            resetButton.setTitleColor(.white, for: .normal)
            resetButton.isEnabled = true
        }
    }
    func resetPressed() {
        dismissKeyboard()
        ProgressHUD.show("In process...", interaction: false)
        Helper.shared.resetPasswordByEmail(withEmail: emailTextField.text!, onSuccess: {
            ProgressHUD.dismiss()
            let controller = UIAlertController(title: "Done!", message: "An e-mail has been sent to you, please follow the instruction to reset your password.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.dismissView()
            })
            controller.addAction(okAction)
            self.present(controller, animated: true)
        }) { (error) in
            ProgressHUD.dismiss()
            let controller = UIAlertController(title: "Something's wrong", message: error, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                self.emailTextField.text = ""
            })
            controller.addAction(okAction)
            self.present(controller, animated: true)
        }
    }
}
