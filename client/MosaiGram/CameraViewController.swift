import UIKit
import RxSwift
import RxCocoa
import ImagePicker
import SwiftyJSON
import CoreGraphics

class CameraViewController: UIViewController,
    ImagePickerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var feedRepository = FeedRepository.sharedRepository
    
    let imagePicker = ImagePickerController()
    let disposeBag = DisposeBag()
    var selectedImages = Variable<[UIImage]>([])
    var gestureRecognizer: UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        saveButton.isEnabled = false
        selectedImages.asObservable()
            .map { $0.count > 0 }
            .bindTo(saveButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleGesture(gesture: )))
        collectionView.addGestureRecognizer(gestureRecognizer!)
    }
    
    //MARK: - GestureRecognizer/CollectionViewInteractiveMovement
    @objc func handleGesture(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        switch gesture.state {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at:location) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(location)
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    //MARK: - ImagePickerControllerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        selectedImages.value = images.map { cropImage(image: $0) }
        self.collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        selectedImages.value = images.map { cropImage(image: $0) }
        self.collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        dismiss(animated: true)
    }
    
    //MARK: - Actions
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func cropImage(image: UIImage) -> UIImage {
        let size = image.size
        let value = min(size.width, size.height)
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        if size.width > size.height {
            x = (size.width - size.height) / CGFloat(2)
        }
        else {
            y = (size.height - size.width) / CGFloat(2)
        }
        let croppingRect = CGRect(x: x, y: y, width: value, height: value)
        guard let imageRef = image.cgImage?.cropping(to: croppingRect) else {
            return image
        }
        let croppedImage = UIImage(cgImage: imageRef, scale: 0.2, orientation: image.imageOrientation)
        return croppedImage
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        var observables = [Observable<JSON>]()
        for image in selectedImages.value {
            
            observables.append(self.feedRepository.uploadImage(image: image))
        }
        Observable.from(observables)
            .merge()
            .subscribe {
                _ in
                self.tabBarController?.selectedIndex = 0
            }
            .addDisposableTo(self.disposeBag)
    }
    
    //MARK: - UICollectionViewDatasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.value.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.cellImageView.image = selectedImages.value[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let result = self.view.bounds.width / 3
        return CGSize(width: result - 8, height: result - 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var cellImageView: UIImageView!
}
