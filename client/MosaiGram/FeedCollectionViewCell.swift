import UIKit
import RxSwift
import RxCocoa

class FeedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var feedImageView: UIImageView!
    let disposeBag = DisposeBag()
    
    private var _imageFetcher: Observable<UIImage>?
    public var imageFetcher: Observable<UIImage>? {
        get { return _imageFetcher }
        set {
            _imageFetcher = newValue
            _imageFetcher?.bindTo(self.feedImageView.rx.image())
                .addDisposableTo(disposeBag)
        }
    }
    override func prepareForReuse() {
        imageFetcher = nil
        feedImageView.image = nil
    }
}
