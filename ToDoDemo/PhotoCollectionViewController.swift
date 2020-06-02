//
//  PhotoCollectionViewController.swift
//  ToDoDemo
//
//  Created by Mars on 21/05/2017.
//  Copyright © 2017 Mars. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class PhotoCollectionViewController: UICollectionViewController {

    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    let bag = DisposeBag()
    
    
    fileprivate lazy var photos = PhotoCollectionViewController.loadPhotos()
    fileprivate lazy var imageManager = PHCachingImageManager()
    
    fileprivate lazy var thumbnailsize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellSpace()
        
        let isAuthorized = PHPhotoLibrary.isAuthorized

//        isAuthorized
//            .skipWhile { $0 == false }
//            .take(1)
//            .subscribe(onNext: {
//                [weak self] _ in
//                // Reload the photo collection view
//                if let `self` = self {
//                    self.photos = PhotoCollectionViewController.loadPhotos()
//                    /// 为什么又使用了DispatchQueue.main.async呢
//                    /// 当我们调用requestAuthorization请求用户授权时，在这个API的说明中，我们可以找到这样一段话：
//                    /// Photos may call your handler block on an arbitrary serial queue. If your handler needs to interact with UI elements, dispatch such work to the main queue
//                    /// 也就是说，我们传递给requestAuthorization的closure参数有可能并不在主线程中执行，
//                    /// 一旦如此，我们订阅的授权结果的代码也就不会在主线程中执行。
//                    /// 但是，由于我们在订阅中更新了UI，如果这个代码不在主线程中，
//                    /// App就会立即闪退了。因为，需要人为保证它执行在主线程里。
//                    DispatchQueue.main.async {
//                        self.collectionView?.reloadData()
//                    }
//                }
//            })
//            .disposed(by: bag)
        
        isAuthorized
        .skipWhile { $0 == false }
        .take(1)
        .observeOn(MainScheduler.instance) // 表示了在主线程中执行订阅代码
        .subscribe(onNext: {
            [weak self] _ in
            // Reload the photo collection view
            if let `self` = self {
                self.photos = PhotoCollectionViewController.loadPhotos()
                self.collectionView?.reloadData()
            }
        })
        .disposed(by: bag)
        
        isAuthorized
        .distinctUntilChanged()
        .takeLast(1)
        .filter { $0 == false }
        .subscribe(onNext: { [weak self] _ in
            self?.flash(title: "Cannot access your photo library",
            message: "You can authorize access from the Settings.",
            callback: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
        })
        .disposed(by: bag)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.onCompleted()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Photo library
extension PhotoCollectionViewController {
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: options)
    }
}

// Collection view related
extension PhotoCollectionViewController {
    func setCellSpace() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.itemSize = CGSize(width: (width-40) / 4, height: (width-40) / 4)
        collectionView!.collectionViewLayout = layout
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoMemo", for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailsize,
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler:
            { (image, _) in
            
                guard let image = image else { return }
            
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.imageView.image = image
                }
            }
        )
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        // 1. Get photo object
        let asset = photos.object(at: indexPath.item)
        // 2. Flip the checked status
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.selected()
        }

        imageManager.requestImage(for: asset,
            targetSize: view.frame.size,
            contentMode: .aspectFill,
            options: nil,
            resultHandler: { [weak self] (image, info) in
                guard let image = image, let info = info else { return }
                /// 只要图片库中的图片不是iCloud中的缩略图
                if let isThumbnail = info[PHImageResultIsDegradedKey] as? Bool,
                   !isThumbnail {
                    // 3. Trigger event if the image is not an icloud
                    // thumbnail.
                    self?.selectedPhotosSubject.onNext(image)
                }
            })
        
    }

}
