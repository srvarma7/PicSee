//
//  GalleryCell.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 07/12/23.
//

import UIKit
import DeepLook
import EasyPeasy

class GalleryCell: UICollectionViewCell {
    static let id = "GalleryCell"
    lazy var iv1: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
//        iv.backgroundColor = .gray.withAlphaComponent(0.5)
//        iv.layer.borderColor = UIColor.red.cgColor
//        iv.layer.borderWidth = 1
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var indicator: UIActivityIndicatorView = {
        let b = UIActivityIndicatorView()
        b.color = .systemPink
        b.hidesWhenStopped = true
        return b
    }()
    
    lazy var faceCompareStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("Reusing cell")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(iv1)
        iv1.easy.layout(Edges())
        
        contentView.addSubview(indicator)
        indicator.easy.layout(Center(), Size(20))
        
        contentView.addSubview(faceCompareStatusLabel)
        faceCompareStatusLabel.backgroundColor = .darkGray
        faceCompareStatusLabel.font = .systemFont(ofSize: 10)
        faceCompareStatusLabel.easy.layout(Bottom(2), Leading(2), Trailing(2))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(face: FaceData) {
        if let cropped = face.cropperFaceImage {
            iv1.image = cropped
        } else {
            iv1.image = face.rawImage
        }
        faceCompareStatusLabel.text = "\(face.distance)"
        faceCompareStatusLabel.textColor = face.distance < 0.7 ? .green : .red
        
        faceCompareStatusLabel.isHidden = face.distance == -999
    }
    
    //    func compare(with selectedImage: UIImage) {
    //        guard let image = iv1.image else {
    //            print("Add image")
    //            indicator.stopAnimating()
    //            return
    //        }
    //
    //        print("comparing")
    //        indicator.startAnimating()
    //
    //        guard let pickerImageEncoding = DeepLook.faceEncodings(image).first, let unknown_encoding = DeepLook.faceEncodings(selectedImage).first else {
    //            return
    //        }
    //
    //        let distance = DeepLook.faceDistance([unknown_encoding], faceToCompare: pickerImageEncoding)
    //        let areSameStatus = distance.first! < 0.7
    //
    //        print("faceDistance", distance.first!)
    //        let val = "D - \(distance.first!)"
    //        faceCompareStatusLabel.text = val
    //        faceCompareStatusLabel.textColor = areSameStatus ? .green : .red
    //        indicator.stopAnimating()
    //    }
}

