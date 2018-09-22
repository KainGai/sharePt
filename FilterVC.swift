import UIKit
import Fusuma
protocol FilterVCDelegate {
    func updateImage(image: UIImage)
}
class FilterVC: UIViewController {
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterImageViewHeight: NSLayoutConstraint!
    var selectedImage: UIImage?
    var delegate: FilterVCDelegate?
    var ciContext: CIContext?
    let filterNames = ["CIPhotoEffectChrome","CIPhotoEffectFade","CIPhotoEffectInstant","CIPhotoEffectMono","CIPhotoEffectProcess","CIPhotoEffectTonal","CIPhotoEffectTransfer"]
    override func viewDidLoad() {
        super.viewDidLoad()
        ciContext = CIContext(options: nil)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewHeight.constant = UIScreen.main.bounds.width / 3
        filterImageViewHeight.constant = UIScreen.main.bounds.width
        navigationItem.title = "Filter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonPressed))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filterImageView.image = selectedImage
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: UICollectionViewScrollPosition(), animated: false)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func nextButtonPressed() {
        let vc = ShareVC()
        vc.imageView.image = filterImageView.image
        navigationController?.pushViewController(vc, animated: true)
    }
    func resizeImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: image.size.width / 10, height: image.size.height / 10))
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width / 10, height: image.size.height / 10))
        if let newImage = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            return newImage
        }
        return image
    }
    func applyFilterToImage(image: UIImage, filterName: String, context: CIContext) -> UIImage {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: filterName)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage, let result = context.createCGImage(filteredImage, from: filteredImage.extent) {
            return UIImage(cgImage: result)
        }
        return image
    }
}
extension FilterVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as? FilterCell{
            let newImage = selectedImage!.resizeUIImage(toWidth: 150)
            cell.selectedImage = applyFilterToImage(image: newImage, filterName: filterNames[indexPath.item], context: ciContext!)
            return cell
        }else {
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newImage = applyFilterToImage(image: selectedImage!, filterName: filterNames[indexPath.item], context: ciContext!)
        if newImage.imageOrientation != selectedImage?.imageOrientation {
            let rotatedImage = newImage.rotateImageByDegrees(deg: 90)
            filterImageView.image = rotatedImage
        }else {
            filterImageView.image = newImage
        }
    }
}
extension FilterVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
