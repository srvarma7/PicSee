//
//  FaceComapareVC.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 01/12/23.
//

import UIKit
import EasyPeasy
import DeepLook

class FaceComapareVC: UIViewController {
    
    lazy var faceCompareStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
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
        iv.tag = 1
        iv.isUserInteractionEnabled = true
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(didTapIV2))
        iv.addGestureRecognizer(tapAction)
        return iv
    }()
    
    lazy var compareButton: UIButton = {
        let b = UIButton(primaryAction: UIAction(handler: { _ in
            self.compare()
        }))
        b.setTitle("Compare", for: .normal)
        return b
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let b = UIActivityIndicatorView()
        b.color = .systemPink
        b.hidesWhenStopped = true
        return b
    }()
    
    private var selectedImageViewTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(faceCompareStatusLabel)
        faceCompareStatusLabel.easy.layout(Left(20), Top(20).to(view, .topMargin), Right(20), Height(15))
        view.addSubview(iv1)
        view.addSubview(iv2)
        
        iv1.easy.layout(Left(10), Top(20).to(faceCompareStatusLabel, .bottom), Size(view.frame.width*0.45))
        iv2.easy.layout(Right(10), Top(20).to(faceCompareStatusLabel, .bottom), Size(view.frame.width*0.45))
        
        view.addSubview(compareButton)
        compareButton.easy.layout(Leading(), Trailing(), Top(20).to(iv1), Height(50))
        
        view.addSubview(indicator)
        indicator.easy.layout(Center(), Size(20))
    }
    
    @objc func didTapIV1() {
        selectedImageViewTag = 0
        presentImagePicker()
    }
    
    @objc func didTapIV2() {
        selectedImageViewTag = 1
        presentImagePicker()
    }
    
    private func compare() {
        guard let image = iv1.image, let image2 = iv2.image else {
            print("Add images")
            return
        }
        
        print("comparing")
        indicator.startAnimating()
        //        let image = UIImage(named: "sai_4")!
        //        let image2 = UIImage(named: "sai_5")!
//        
//        let image = UIImage(named: "single1")!
//        let image2 = UIImage(named: "single2")!
//        
//        
//        
//        
//        // find face locations
//        let faceLocations = DeepLook.faceLocation(image) // Normalized rect. [CGRect]
//        
//        // get list of face chips images.
//        let corppedFaces = DeepLook.cropFaces(image, locations: faceLocations)
//        
//        
//        // get facial landmarks for each face in the image.
//        let faceLandmarks = DeepLook.faceLandmarks(image) // [VNFaceLandmarkRegion2D]
//        
//        let faceLandmarksPoints = faceLandmarks.map({ $0.normalizedPoints })
//        
//        
//        // get image size
//        let imageSize =  CGSize(width: image.cgImage!.width, height: image.cgImage!.height)
//        
//        // convert to UIKit coordinate system.
//        let points = faceLandmarks.map({ (landmarks) -> [CGPoint] in
//            landmarks.pointsInImage(imageSize: imageSize)
//                .map({ (point) -> CGPoint in
//                    CGPoint(x: point.x, y: imageSize.height - point.y)
//                })
//        })
//        
//        let faceLandmarks2 = DeepLook.faceLandmarks(image, knownFaceLocations: faceLocations)
//        
        
        // encode faces in both images.
        let angelina_encoding = DeepLook.faceEncodings(image)[0] // array of encoding faces.
        let unknown_encoding = DeepLook.faceEncodings(image2)[0] // array of encoding faces.
        
        // return result for each faces in the source image.
        // treshold default is set to 0.6.
        let result = DeepLook.compareFaces([unknown_encoding], faceToCompare: angelina_encoding, threshold: 0.7) // [Bool]
        print(result)
        if let status = result.first {
            let val = "Faces are: \(status ? "identical" : "not identical")"
            faceCompareStatusLabel.text = val
            faceCompareStatusLabel.textColor = status ? .green : .red
            indicator.stopAnimating()
        }
        // get array of double represent the l2 norm euclidean distance.
        let results = DeepLook.faceDistance([unknown_encoding], faceToCompare: angelina_encoding) // [Double]
        print("faceDistance", results.first!)
//
//        // return list of faces emotions `[Face.FaceEmotion]`.
//        let emotions = DeepLook.faceEmotion(image)
//        print(emotions)
//        let emotions2 = DeepLook.faceEmotion(image2)
//        print(emotions2)
    }
}


extension FaceComapareVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedPhoto = info[.originalImage] as? UIImage else {
            return
        }
        dismiss(animated: true, completion: { [unowned self, selectedPhoto] in
            switch self.selectedImageViewTag {
                case 0:
                    self.iv1.image = selectedPhoto
                case 1:
                    self.iv2.image = selectedPhoto
                default:
                    fatalError("Unexpected behaviour")
            }
            self.compare()
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
