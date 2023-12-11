//
//  HeaderCell.swift
//  PicSee
//
//  Created by Sai Raghu Varma Kallepalli on 07/12/23.
//

import UIKit
import EasyPeasy

class HeaderCell: UICollectionReusableView {
    
    static let id = "HeaderCell"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(label)
        label.textAlignment = .left
        label.easy.layout(Edges())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
