//
//  WeatherListVM.swift
//  WeatherApp
//
//  Created by Prabhjot Singh Gogana on 19/6/2022.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay


enum WeatherNetworkError {
    case internetError(String)
    case serverMessage(String)
}

class WeatherListVM {
    var weatherList$ = BehaviorRelay<[WeatherList]?>(value: nil)
    var emptyWeatherList = [WeatherList(), WeatherList(), WeatherList(), WeatherList()]
    let loading: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let error : PublishSubject<WeatherNetworkError> = PublishSubject()
    let disposable = DisposeBag()
    
    func requestWeatherData() {
/*        Added the url with base url. get parameters can put on parameter as well but it will work too just for API. I prefer my generic API https://github.com/prabhjot-singh-gogana/PSAPI
         which work with Alamofire please have a look.
 */

        self.loading.accept(true)

        APIManager<Response>.requestData(requestURL: .list, method: .get, parameters: nil) { (result) in
            // just putting the delay so that can check the waiting time
            switch result {
            case .success(let object):
//                self.loading.onNext(false)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self.loading.accept(false)
                    self.weatherList$.accept(object.list)
                })
            case .failure(let failure) :
//                self.loading.onNext(false)
                switch failure {
                case .connectionError:
                    self.error.onNext(.internetError("Check your Internet connection."))
                case .authorizationError:
                    self.error.onNext(.serverMessage("Server Error"))
                default:
                    self.error.onNext(.serverMessage("Unknown Error"))
                }
            }
        }
    }
}

