//
//  CellForWeatherList.swift
//  CellForWeatherList
//
//  Created by Prabhjot Singh Gogana on 25/06/22.
//

import UIKit

class CellForWeatherList: UITableViewCell {
    @IBOutlet weak var lblNameCity: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateTheCell(with weatherList: WeatherList) {
        self.lblTemp.text = "\(weatherList.main?.temp ?? 0)"
        self.lblNameCity.text = weatherList.name ?? ""
    }
}
