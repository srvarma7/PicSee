//
//  FaceDetectorVC.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 27/11/23.
//

import UIKit
import Vision
import CoreML

class DetecingFaceVC: UIViewController {
    var image = UIImage(named: "image1")!
    lazy var imageView = UIImageView(image: image)
    
    // 绘制的矩形区域
    var boxViews: [UIView] = []
    
    // 图像分析请求
    lazy var imageRequestHandler = VNImageRequestHandler(cgImage: image.cgImage!,
                                                         orientation: .up,
                                                         options: [:])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let scale = image.size.width / image.size.height
        
        let width = self.view.frame.size.width
        imageView.frame = CGRect(x: 0, y: 100, width: width, height: width / scale)
        view.addSubview(imageView)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.imageRequestHandler.perform([self.faceDetectionRequest])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
    private lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
        let faceDetectRequest = VNDetectFaceRectanglesRequest { request, error in
            DispatchQueue.main.async {
                self.drawTask(request: request as! VNDetectFaceRectanglesRequest)
            }
        }
        return faceDetectRequest
    }()
    
    private func drawTask(request: VNDetectFaceRectanglesRequest) {
        boxViews.forEach { v in
            v.removeFromSuperview()
        }
        for result in request.results ?? [] {
            var box = result.boundingBox
            box.origin.y = 1 - box.origin.y - box.size.height
            let v = UIView()
            v.backgroundColor = .clear
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 2
            imageView.addSubview(v)
            let size = imageView.frame.size
            v.frame = CGRect(x: box.origin.x * size.width, y: box.origin.y * size.height, width: box.size.width * size.width, height: box.size.height * size.height)
            boxViews.append(v)
        }
    }
    
    
}

