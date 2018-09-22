import UIKit
import paper_onboarding
class OnboardingVC: UIViewController {
    lazy var onboardingView: PaperOnboarding = {
        let view = PaperOnboarding.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        return view
    }()
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        let attribute = [NSFontAttributeName : UIFont(name: "AvenirNext-Bold", size: 20)!]
        let string = NSAttributedString(string: "GET STARTED", attributes: attribute)
        button.setAttributedTitle(string, for: .normal)
        button.tintColor = .black
        button.alpha = 0
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        snowCherry()
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func setupView() {
        view.addSubview(onboardingView)
        view.addSubview(startButton)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": onboardingView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": onboardingView]))
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v0]-75-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": startButton]))
    }
    func startButtonPressed() {
        let sb = UIStoryboard(name: "Start", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignInVC")
        present(vc, animated: true) { 
            UserDefaults.standard.set(true, forKey: "Onboarding")
            UserDefaults.standard.synchronize()
        }
    }
}
extension OnboardingVC {
    func snowCherry() {
        let emitterLayer = Emitter.createEmitter(with: kCAEmitterLayerLine, with: #imageLiteral(resourceName: "cherry_white"))
        emitterLayer.emitterPosition = CGPoint(x: view.frame.width / 2, y: 0)
        emitterLayer.emitterSize = CGSize(width: view.frame.width, height: 1)
        view.layer.addSublayer(emitterLayer)
    }
}
extension OnboardingVC: PaperOnboardingDataSource, PaperOnboardingDelegate {
    func onboardingItemsCount() -> Int {
        return 3
    }
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let color2 = UIColor(red: 175/255, green: 250/255, blue: 193/255, alpha: 1)
        let color1 = UIColor(red: 255/255, green: 216/255, blue: 216/255, alpha: 1)
        let color3 = UIColor(red: 186/255, green: 231/255, blue: 241/255, alpha: 1)
        let titleFont = UIFont(name: "AvenirNext-Bold", size: 28)!
        let descriptionFont = UIFont(name: "AvenirNext-Regular", size: 20)!
        if(index == 0)
        {
            return OnboardingItemInfo.init(informationImage: UIImage.init(named: "onboarding_icon_white")!, title: "Welcome To sharePt", description: "Sign in to start sharing your moments with the world.", pageIcon: UIImage.init(), color: color1, titleColor: .white, descriptionColor: .white, titleFont: titleFont, descriptionFont: descriptionFont)
        }else if(index == 1)
        {
            return OnboardingItemInfo.init(informationImage: UIImage.init(named: "onboarding_discover_more")!, title: "Discover More", description: "All the moments that make you smile and enjoy life.", pageIcon: UIImage.init(), color: color2, titleColor: .white, descriptionColor: .white, titleFont: titleFont, descriptionFont: descriptionFont)
        }else
        {
            return OnboardingItemInfo.init(informationImage: UIImage.init(named: "onboarding_up_to_date")!, title: "Stay Up To Date", description: "Get notified of things you are interested in.", pageIcon: UIImage.init(), color: color3, titleColor: .white, descriptionColor: .white, titleFont: titleFont, descriptionFont: descriptionFont)
        }
    }
    func onboardingWillTransitonToIndex(_ index: Int) {
        if(index == 1) {
            UIView.animate(withDuration: 0.2, animations: { 
                self.startButton.alpha = 0
            })
        }
    }
    func onboardingDidTransitonToIndex(_ index: Int) {
        if(index == 2) {
            UIView.animate(withDuration: 0.3, animations: {
                self.startButton.alpha = 1
            })
        }
    }
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
    }
}
