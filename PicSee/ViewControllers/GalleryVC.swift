//
//  GalleryVC.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 06/12/23.
//

import UIKit
import Photos
import PhotosUI
import EasyPeasy

class GalleryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var assets = [PHAsset]()
    var images = [UIImage]()
    let page = 100
    var beginIndex = 0
    
    var endIndex = 9
    var allPhotos : PHFetchResult<PHAsset>?
    var loading = false
    var hasNextPage = false
    
    var collectionView : UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .cyan
        collectionView.backgroundColor = .brown
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.id)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        allPhotos = PHAsset.fetchAssets(with: .image, options: options)
        getImages()
    }
    
    func getImages() {
        endIndex = beginIndex + (page - 1)
        if endIndex > allPhotos!.count {
            endIndex = allPhotos!.count - 1
        }
        let arr = Array(beginIndex...endIndex)
        
        let indexSet = IndexSet(arr)
        fetchPhotos(indexSet: indexSet)
//        fetchCustomAlbumPhotos()
    }
    
    func fetchCustomAlbumPhotos() {
        let albumName = "Face"
        var assetCollection = PHAssetCollection()
        
        var photoAssets = PHFetchResult<PHAsset>()
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collection.firstObject {
            //found the album
            assetCollection = firstObject
        }
        
        _ = collection.count
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        let imageManager = PHCachingImageManager()
        photoAssets.enumerateObjects { (object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if object is PHAsset {
                let asset = object as! PHAsset
                
                let quality = 500.0
                let imageSize = CGSize(width: quality, height: quality)
                
                /* For faster performance, and maybe degraded image */
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) -> Void in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                    }
                })
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        allPhotos = photoAssets
    }
    
    
    fileprivate func fetchPhotos(indexSet: IndexSet) {
        
        if allPhotos!.count == self.images.count {
            self.hasNextPage = false
            self.loading = false
            return
        }
        
        self.loading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.allPhotos?.enumerateObjects(at: indexSet, options: NSEnumerationOptions.reverse, using: { (asset, count, stop) in
                
                guard let weakSelf = self else {
                    return
                }
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 250, height: 250)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        weakSelf.images.append(image)
                        weakSelf.assets.append(asset)
                    }
                    
                })
                if weakSelf.images.count - 1 == indexSet.last! {
                    print("last element")
                    weakSelf.loading = false
                    weakSelf.hasNextPage = weakSelf.images.count != weakSelf.allPhotos!.count
                    weakSelf.beginIndex = weakSelf.images.count
                    DispatchQueue.main.async {
                        weakSelf.collectionView.reloadData()
                    }
                }
            })
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.id, for: indexPath) as! GalleryCell
        cell.iv1.image = images[indexPath.row]
        
        if hasNextPage && !loading && indexPath.row == self.images.count - 1 {
            getImages()
        }
        
        return cell
    }
    
    let numOfImagesPerRow = 3.0
    let padding: CGFloat = 0
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width / numOfImagesPerRow) - padding
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 0, left: padding, bottom: 0, right: padding)
    }
}


