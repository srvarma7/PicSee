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
    case deviation = "Deviation"
    case gallery = "Gallery"
}

class ViewController: UIViewController {
    
    let data = Actions.allCases
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        tableView(tableView, didSelectRowAt: IndexPath(row: 4, section: 0))
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
            case .deviation:
                let vc = DeviationVC()
                navigationController?.pushViewController(vc, animated: true)
                break
            case .gallery:
                let vc = GalleryVC()
                navigationController?.pushViewController(vc, animated: true)
        }
    }
}
