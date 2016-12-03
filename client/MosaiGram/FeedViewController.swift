import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

class FeedViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

    @IBOutlet weak var collectionView: UICollectionView!
    var feedRepository = FeedRepository.sharedRepository
    var feedDatasource = Variable<[JSON]>([])
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = self
        feedRepository.feed
            .asObservable()
            .bindTo(feedDatasource)
            .addDisposableTo(disposeBag)
        feedDatasource.asObservable().subscribe {
            [weak self]
            _ in
            self?.collectionView.reloadData()
        }.addDisposableTo(disposeBag)
    }
    
    //MARK: - UICollectionViewDatasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedDatasource.value.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedItem = feedDatasource.value[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedCollectionViewCell
        let url = feedItem["url"].string ?? ""
        if let image = feedRepository.images.value[url] {
            cell.feedImageView.image = image
        }
        else {
            cell.imageFetcher = feedRepository.fetchImage(url: url)
        }
        return cell
    }
    
    //MARK: - UICollectionViewDatasourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print(indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            print(indexPath)
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let amount = self.view.bounds.size.width / 3
        return CGSize(width: amount, height: amount)
    }
}
