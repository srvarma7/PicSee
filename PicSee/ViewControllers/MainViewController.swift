//
//  ViewController.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 27/11/23.
//

import UIKit

enum Actions: String, CaseIterable {
    case allImages = "All Images"
    case faceDetect = "Detect Face"
    case faceaCompare = "Compare Face"
}

class ViewController: UIViewController {
    
    let data = Actions.allCases
    
    let images = [
        "IMG_1"
    ]
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PicSee"
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        view.backgroundColor = .red
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.id)
        tableView.rowHeight = 50
        tableView.estimatedRowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        
//        trainImages()
        
//        let image = UIImage(named: "sai_1")!
//        let image = UIImage(named: "image5")!
//        let person = PersonImage(image: image.cgImage!, rect: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
//        
//        let featureValue = person.featureValue
//        
//        let predict = ModelUpdater.predictLabelFor(featureValue)
//        
//        let name = predict ?? "Unknown"
//        print("This is \(name)")
        
    }
    
    
    
//    func trainImages() {
//        let saiImages = [
//            "sai_1",
//            "sai_2",
//            "sai_3",
//            "sai_4",
//            "sai_5",
//            "sai_6",
//            "sai_7",
//        ]
//
//        var training = PersonTrainingSet(for: "Sai")
//        saiImages.forEach({
//            let image = UIImage(named: $0)!
//            training.addPerson(PersonImage(image: image.cgImage!, rect: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)))
//        })
//
//        let drawingTrainingData = training.featureBatchProvider
//
//        // Update the Drawing Classifier with the drawings.
//        DispatchQueue.global(qos: .userInitiated).async {
//            ModelUpdater.updateWith(trainingData: drawingTrainingData) {
//                DispatchQueue.main.async { self.dismiss(animated: true, completion: nil) }
//            }
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView(tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.id, for: indexPath)
        cell.textLabel?.text = data[indexPath.row].rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch data[indexPath.row] {
            case .allImages:
                let vc = AllImagesVC()
                navigationController?.pushViewController(vc, animated: true)
            case .faceDetect:
                let vc = DetecingFaceVC()
                vc.image = UIImage(named: "image1")!
                present(vc, animated: true)
                break
            case .faceaCompare:
                let vc = FaceComapareVC()
                navigationController?.pushViewController(vc, animated: true)
        }
    }
}
