import UIKit
import TextFieldEffects
import ProgressHUD
import AVFoundation
class ShareVC: UIViewController {
    var videoUrl: URL?
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    let separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    lazy var captionTextField: HoshiTextField = {
        let field = HoshiTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Say Something?"
        field.borderInactiveColor = .darkGray
        field.borderActiveColor = .orange
        field.autocapitalizationType = .none
        field.font = UIFont(name: "Avenir Next", size: 18)
        field.returnKeyType = .done
        field.delegate = self
        return field
    }()
    let featurLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let attribute = [NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 15)!]
        let string = NSAttributedString(string: "More Features Coming Soon...", attributes: attribute)
        label.attributedText = string
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MAIN_COLOR
        setupView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareButtonPressed))
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func setupView() {
        view.addSubview(imageView)
        view.addSubview(separator)
        view.addSubview(captionTextField)
        view.addSubview(featurLabel)
        imageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 5).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.width / 3).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : separator]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0(1)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0" : separator]))
        separator.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        captionTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        captionTextField.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: -10).isActive = true
        captionTextField.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 5).isActive = true
        captionTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        featurLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        featurLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 15).isActive = true
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension ShareVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}
extension ShareVC {
    func shareButtonPressed() {
        dismissKeyboard()
        ProgressHUD.show("Posting...", interaction: false)
        if let image = imageView.image, let imageData = UIImageJPEGRepresentation(image, 0.5), let thumbnail = imageView.image?.resizeUIImage(toWidth: 200), let thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.5) {
            if let videoUrl = videoUrl {
                Api.STORAGE.uploadVideoToStorage(url: videoUrl, onSuccess: { (videoURL) in
                    Api.STORAGE.uploadImageToStorage(imageData: imageData, thumbnailData: thumbnailData, onSuccess: { (dict) in
                        self.sendDataToDatabase(photoUrl: dict["imageUrl"]!, thumbnailUrl: dict["thumbnailUrl"]!, videoUrl: videoURL)
                    }, onError: { (error) in
                        print(error!)
                    })
                }, onError: { (error) in
                    print(error!)
                })
            }else {
                Api.STORAGE.uploadImageToStorage(imageData: imageData, thumbnailData: thumbnailData, onSuccess: { (dict) in
                    self.sendDataToDatabase(photoUrl: dict["imageUrl"]!, thumbnailUrl: dict["thumbnailUrl"]!, videoUrl: nil)
                }, onError: { (error) in
                    ProgressHUD.showError(error?.localizedDescription, interaction: false)
                })
            }
        }else {
            ProgressHUD.showError("Something's Wrong", interaction: false)
        }
    }
    func generateThumbnailImageForVideo(url: URL) -> UIImage?{
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true 
        do {
            let image = try generator.copyCGImage(at: CMTimeMake(0,10), actualTime: nil)
            return UIImage(cgImage: image)
        } catch let error{
            print(error)
        }
        return nil
    }
    func sendDataToDatabase(photoUrl: String, thumbnailUrl: String, videoUrl: String?) {
        let newPostRef = Api.POST.REF_POSTS.childByAutoId()
        let newPostRefKey = newPostRef.key
        let newHashTagRef = Api.HASHTAG.REF_HASHTAG
        guard let uid = Api.USER.CURRENT_USER?.uid else {
            return
        }
        if let text = captionTextField.text {
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            for word in words {
                let hashTag = word.trimmingCharacters(in: .punctuationCharacters).lowercased()
                if(hashTag != "") {
                    newHashTagRef.child(hashTag).updateChildValues([newPostRefKey:true])
                }
            }
        }
        let timestamp = Int(Date().timeIntervalSince1970)
        var dict = ["uid" : uid, "photoUrl" : photoUrl, "thumbnailUrl" : thumbnailUrl, "caption" : captionTextField.text!, "likeCount" : 0, "timestamp" : timestamp] as [String : Any]
        if let videoUrl = videoUrl {
            dict["videoUrl"] = videoUrl
        }
        newPostRef.setValue(dict, withCompletionBlock: {
            (error, ref) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription, interaction: false)
                return
            }
            Api.FEED.saveNewFeedAndUpdateFollower(uid: uid, postId: newPostRef.key, timestamp: timestamp)
            Api.NOTIFICATION.sendNotification(from: uid, type: "post", objectID: newPostRefKey, timestamp: timestamp)
            Api.USER_POST.REF_USER_POST.child(uid).child(newPostRef.key).setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription, interaction: false)
                    return
                }
            })
            ProgressHUD.showSuccess("Success")
            self.captionTextField.text = ""
            self.dismiss(animated: true, completion: { 
                self.tabBarController?.selectedIndex = 0
            })
        })
    }
}
