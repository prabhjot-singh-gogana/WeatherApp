//
//  WeatherList.swift
//  WeatherApp
//
//  Created by Prabhjot Singh Gogana on 19/6/2022.
//

import UIKit
import RxSwift
import RxCocoa


import Foundation

// MARK: - Response
struct Response: Codable, PSJsonDecoding {
    typealias PSMapperModel = Response
    
    var cod: String?
    var calctime: Double?
    var cnt: Int?
    var list: [WeatherList]
}

// MARK: - List
struct WeatherList: Codable, PSJsonDecoding {
    typealias PSMapperModel = WeatherList
    var id: Int?
    var name: String?
    var coord: Coord?
    var main: MainTemp?
    var dt: Int?
    var wind: Wind?
    var rain: Rain?
    var clouds: Clouds?
    var weather: [Weather]?
    var sys: Sys?
    
    init() {
        
    }
}

// MARK: - Clouds
struct Clouds: Codable , PSJsonDecoding {
    typealias PSMapperModel = Clouds
    var all: Int?
}

// MARK: - Coord
struct Coord: Codable , PSJsonDecoding {
    typealias PSMapperModel = Coord
    var lon, lat: Double?
}

// MARK: - Main
struct MainTemp: Codable , PSJsonDecoding {
    typealias PSMapperModel = MainTemp
    var temp, tempMin, tempMax, pressure: Double?
    var seaLevel, grndLevel: Double?
    var humidity: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
    }
}

// MARK: - Rain
struct Rain: Codable, PSJsonDecoding {
    typealias PSMapperModel = Rain
    var the3H: Double?

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - Weather
struct Weather: Codable, PSJsonDecoding {
    typealias PSMapperModel = Weather
    var id: Int?
    var main, weatherDescription, icon: String?

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable, PSJsonDecoding {
    typealias PSMapperModel = Wind
    var speed, deg: Double
}

// MARK: - Sys
struct Sys: Codable {
    var type, id: Int?
    var message: Double?
    var country: String?
    var sunrise, sunset: Int?
}
