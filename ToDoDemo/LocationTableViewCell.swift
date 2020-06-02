//
//  LocationTableViewCell.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/20.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    static let reuseIdentifier = "LocationCell"
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with viewModel: LocationRepresentable) {
        label.text = viewModel.labelText
    }
}
