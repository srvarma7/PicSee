//
//  ClusterVC.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 05/12/23.
//

import UIKit
import EasyPeasy
import DeepLook
import AVFoundation
import Photos

enum Cluster: String {
    case matched
    case unmatched
    case all
    case noFace
}

class ClusterSet {
    let kind: Cluster
    var faces: [FaceData]
    
    init(kind: Cluster, faces: [FaceData]) {
        self.kind = kind
        self.faces = faces
    }
}

class FaceData {
    var rawImage: UIImage
    var cropperFaceImage: UIImage? = nil
    var distance: CGFloat
    var detection: Cluster = .all
    
    init(image: UIImage, distance: CGFloat) {
        self.rawImage = image
        self.distance = distance
    }
}

class DeviationVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let vm = ClusterVM()
    
    lazy var iv1: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .gray.withAlphaComponent(0.5)
        iv.layer.borderColor = UIColor.red.cgColor
        iv.layer.borderWidth = 1
        iv.tag = 0
        iv.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(didTapIV1))
        iv.addGestureRecognizer(tapAction)
        return iv
    }()
    
    lazy var iv2: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .gray.withAlphaComponent(0.5)
        iv.layer.borderColor = UIColor.red.cgColor
        iv.layer.borderWidth = 1
        iv.tag = 0
        iv.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(didTapIV1))
        iv.addGestureRecognizer(tapAction)
        return iv
    }()
    
    lazy var compare: UIButton = {
        let iv = UIButton()
        iv.setTitle("Compare", for: .normal)
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(compareDidTap))
        iv.addGestureRecognizer(tapAction)
        return iv
    }()
    
    @objc func compareDidTap() {
        vm.clusterNewFaces()
    }
    
    lazy var indicator: UIActivityIndicatorView = {
        let b = UIActivityIndicatorView()
        b.color = .systemPink
        b.hidesWhenStopped = true
        return b
    }()
    
    var collectionView : UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.delegate = self
        
        view.addSubview(iv1)
        iv1.easy.layout(Top(10).to(view, .topMargin), CenterX(), Size(80))
        
        view.addSubview(iv2)
        iv2.easy.layout(Top(10).to(view, .topMargin), Trailing(20), Size(80))
        
        view.addSubview(compare)
        compare.setTitleColor(.systemBlue, for: .normal)
        compare.easy.layout(Leading(20), Trailing(20).to(iv1), CenterY().to(iv1), Height(60))
        
        view.addSubview(collectionView)
        collectionView.easy.layout(Top(20).to(iv1), Leading(), Trailing(), Bottom())

        view.addSubview(indicator)
        indicator.easy.layout(Center(), Size(20))
        
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.id)
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCell.id)

        collectionView.dataSource = self
        collectionView.delegate = self
        
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                print(status)
            }
        }
        
        vm.getFaceAlbum()
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vm.cluster.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.cluster[section].faces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.id, for: indexPath) as! GalleryCell
//        cell.iv1.image = vm.images[indexPath.row]
//        cell.iv1.image = vm.cluster[indexPath.section].faces[indexPath.row].image
        cell.bind(face: vm.cluster[indexPath.section].faces[indexPath.row])
        
//        if let pickerImage = iv1.image {
//            cell.compare(with: pickerImage)
//        }
//        cell.bind(face: vm.cluster[indexPath.section])
        
        if vm.hasNextPage && !vm.loading && indexPath.row == vm.images.count - 1 {
            vm.getFaceAlbum()
        }
        
        return cell
    }
    
    let numOfImagesPerRow = 5.0
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
        return .init(top: 2, left: padding, bottom: 10, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCell.id, for: indexPath) as! HeaderCell
            header.label.text = vm.cluster[indexPath.section].kind.rawValue
            header.backgroundColor = vm.cluster[indexPath.section].kind == .matched ? .green : .red
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 20)
    }
    
    @objc func didTapIV1() {
        presentImagePicker()
    }
    
    private func facerecCluster() {
        Task {
            do {
                let options = AssetFetchingOptions(sortDescriptors: nil,
                                                   assetCollection: .allPhotos,
                                                   fetchLimit: 2)
                
                // Create cluster options.
                let clusterOptions = ClusterOptions()
                
                // Start clustering
                let cluster = try await Recognition.cluster(fetchOptions: options, clusterOptions: clusterOptions)
                
                print("cluster complete", cluster)
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                }
            } catch {
                print(error)
            }
        }
    }
    
    private func clusterForPerson(image: UIImage) {
        indicator.startAnimating()
        
        let fetchAssetOptions = AssetFetchingOptions(sortDescriptors: nil,
                                                     assetCollection: .albumName("Face"),
                                                     fetchLimit: 3)
        
        let cofig = ProcessConfiguration()
        cofig.faceEncoderModel = .facenet
        cofig.landmarksAlignmentAlgorithm = .pointsSphereFace5
        cofig.faceChipPadding = 0.0
        
        let faceLocations = DeepLook.faceLocation(image)
        let croppedFace = DeepLook.cropFaces(image, locations: faceLocations).first!
        
        iv1.image = croppedFace
        
        Task {
            do {
                let matches = try await Recognition.find(sourceImage: croppedFace,
                                                         galleyFetchOptions: fetchAssetOptions,
                                                         similarityThreshold: 0.5)
                print("match complete", matches.count)
                
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func imageDidPick(image: UIImage) {
        let faceLocation = DeepLook.faceLocation(image)
        let croppedFace = DeepLook.cropFaces(image, locations: faceLocation)
        if let first = croppedFace.first {
            iv2.image = first
        } else {
            print("*** no face ***")
        }
        
        iv1.image = image
        vm.pickedImage = image
    }
}

extension DeviationVC: ClusterDelegate {
    func didFetchNewPhotos() {
        collectionView.reloadData()
    }
    
    func didClusterNewPhotos() {
        collectionView.reloadData()
    }
}

extension DeviationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            return
        }
        dismiss(animated: true, completion: { [unowned self, selectedPhoto] in
            self.imageDidPick(image: selectedPhoto)
        })
    }
    
    func presentImagePicker() {
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Image",
                                                       message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { [unowned self] (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { [unowned self] (alert) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        imagePickerActionSheet.addAction(libraryButton)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        imagePickerActionSheet.addAction(cancelButton)
        present(imagePickerActionSheet, animated: true)
    }
}
