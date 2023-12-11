//
//  ClusterVM.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 07/12/23.
//

import DeepLook
import Photos
import UIKit

protocol ClusterDelegate: AnyObject {
    func didFetchNewPhotos()
    func didClusterNewPhotos()
}

class ClusterVM {
    
    weak var delegate: ClusterDelegate?
    
    var pickedImage: UIImage?
    
    var assets = [PHAsset]()
    var cluster: [ClusterSet] = []
    var images = [UIImage]()
    let page = 19
    var beginIndex = 0
    
    var endIndex = 9
    var allPhotos : PHFetchResult<PHAsset>?
    var loading = false
    var hasNextPage = false
    let imageManager = PHCachingImageManager()
    
    init() {
        let albumName = "Face"
//        let albumName = "Chad"
        var assetCollection = PHAssetCollection()
        
        var photoAssets = PHFetchResult<PHAsset>()
        let fetchOptions = PHFetchOptions()
        
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collection.firstObject {
            //found the album
            assetCollection = firstObject
        }
        photoAssets = PHAsset.fetchAssets(in: assetCollection, options: nil)
        allPhotos = photoAssets
    }
    
    func getFaceAlbum() {
        endIndex = beginIndex + (page - 1)
        if endIndex > allPhotos!.count {
            endIndex = allPhotos!.count - 1
        }
        let arr = Array(beginIndex...endIndex)
        
        let indexSet = IndexSet(arr)
        fetchPhotos(indexSet: indexSet)
    }
    
    func fetchPhotos(indexSet: IndexSet) {
        
        if allPhotos!.count == images.count {
            hasNextPage = false
            loading = false
            return
        }
        
        loading = true
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.allPhotos!.enumerateObjects(at: indexSet) { (object: AnyObject!, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                
                guard let weakSelf = self else {
                    return
                }
                
                if object is PHAsset {
                    let asset = object as! PHAsset
                    
                    let quality = 500.0
                    let imageSize = CGSize(width: quality, height: quality)
                    
                    /* For faster performance, and maybe degraded image */
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    options.isSynchronous = true
                    
                    weakSelf.imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options, resultHandler: { (image, info) -> Void in
                        if let image = image {
                            weakSelf.addNewAsset(image: image, asset: asset)
                        }
                    })
                    
                    if weakSelf.images.count - 1 == indexSet.last! {
                        print("last element")
                        print("total fetched", weakSelf.images.count)
                        weakSelf.loading = false
                        weakSelf.hasNextPage = weakSelf.images.count != weakSelf.allPhotos!.count
                        weakSelf.beginIndex = weakSelf.images.count
                        
                        DispatchQueue.main.async {
                            print("Indexset fetched")
                            weakSelf.delegate?.didFetchNewPhotos()
                        }
                    }
                }
            }
        }
    }
    
    func addNewAsset(image: UIImage, asset: PHAsset) {
        images.append(image)
        assets.append(asset)
        
        if let firstIndexOfAll = cluster.firstIndex(where: { $0.kind == .all }) {
            cluster[firstIndexOfAll].faces.append(FaceData(image: image, distance: -999))
        } else {
            cluster.append(ClusterSet(kind: .all, faces: [FaceData(image: image, distance: -999)]))
        }
        
        print("new image and added")
    }
    
    func clusterNewFaces() {
        guard let pickedImage else {
            print("Image not picker")
            return
        }
        
        if let firstIndexOfAll = cluster.firstIndex(where: { $0.kind == .all }) {
            
            for (faceIndex, faceItem) in cluster[firstIndexOfAll].faces.reversed().enumerated() {
                print("person index", faceIndex)
                
                let pickedFaceLocation = DeepLook.faceLocation(pickedImage)
                let objFaceLocation = DeepLook.faceLocation(faceItem.rawImage)
                
                let croppedPickedFaceLocation = DeepLook.cropFaces(pickedImage, locations: pickedFaceLocation)
                let croppedObjFaceLocation = DeepLook.cropFaces(faceItem.rawImage, locations: objFaceLocation)
                
                if let croppedPicked = croppedPickedFaceLocation.first,  let croppedObj = croppedObjFaceLocation.first {
                    faceItem.cropperFaceImage = croppedObj
                    
                    let model: ProcessConfiguration.FaceEncoderModel = .facenet
                    // optimise using face locations
                    if let pickedImageEncoding = DeepLook.faceEncodings(croppedPicked, model: model).first, let objImageEncoding = DeepLook.faceEncodings(croppedObj, model: model).first {
                        
                        let distance = DeepLook.faceDistance([objImageEncoding], faceToCompare: pickedImageEncoding).first!
                        let areSameStatus = distance < 0.85
                        faceItem.distance = distance
                        //                    cluster[firstIndexOfAll].faces[faceIndex].detection = areSameStatus ? .matched : .unmatched
                        //                    cluster[firstIndexOfAll].faces[faceIndex].distance = distance
                        
                        if areSameStatus {
                            print("same person")
                            if let firstIndexOfMatched = cluster.firstIndex(where: { $0.kind == .matched }) {
                                cluster[firstIndexOfMatched].faces.append(faceItem)
                            } else {
                                cluster.append(ClusterSet(kind: .matched, faces: [faceItem]))
                            }
                        } else {
                            print("not same person")
                            if let firstIndexOfUnmatched = cluster.firstIndex(where: { $0.kind == .unmatched }) {
                                cluster[firstIndexOfUnmatched].faces.append(faceItem)
                            } else {
                                cluster.append(ClusterSet(kind: .unmatched, faces: [faceItem]))
                            }
                        }
                        
                    }
                } else {
                    
                    //                    cluster[firstIndexOfAll].faces[faceIndex].detection = .noFace
                    
                    print("noFace found")
                    if let firstIndexOfNoFace = cluster.firstIndex(where: { $0.kind == .noFace }) {
                        cluster[firstIndexOfNoFace].faces.append(faceItem)
                    } else {
                        cluster.append(ClusterSet(kind: .noFace, faces: [faceItem]))
                    }
                    
                    
                }
                
            }
            
            cluster.remove(at: firstIndexOfAll)
        }
        
        DispatchQueue.main.async {
            print("didClusterNewPhotos")
            self.delegate?.didClusterNewPhotos()
        }
    }
}
