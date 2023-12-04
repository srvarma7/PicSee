//
//  AllImagesVC.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 01/12/23.
//

import UIKit

class AllImagesVC: UIViewController {
    
    let images = [
        "image1",
    ]
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(ImageCell.self, forCellReuseIdentifier: ImageCell.id)
        tableView.rowHeight = 400
        tableView.estimatedRowHeight = 400
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension AllImagesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.id, for: indexPath) as! ImageCell
        cell.dImageView.image = UIImage(named: images[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetecingFaceVC()
        vc.image = UIImage(named: images[indexPath.row])!
        present(vc, animated: true)
    }
}


class ImageCell: UITableViewCell {
    
    static let id = "ImageCell"
    
    let dImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(dImageView)
        dImageView.contentMode = .scaleAspectFit
        contentView.clipsToBounds = true
        dImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            dImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

