//
//  WeekWeatherTableViewCell.swift
//  ToDoDemo
//
//  Created by wangxiangbo on 2020/5/19.
//  Copyright © 2020 Mars. All rights reserved.
//

import UIKit
class WeekWeatherTableViewCell: UITableViewCell {

    static let reuseIdentifier = "WeekWeatherCell"

    @IBOutlet weak var week: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var humid: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with vm: WeekWeatherDayRepresentable) {
        week.text = vm.week
        date.text = vm.date
        humid.text = vm.humidity
        temperature.text = vm.temperature
        weatherIcon.image = vm.weatherIcon
    }

}
