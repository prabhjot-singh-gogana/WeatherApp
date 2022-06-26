//
//  DetailOfWeatherVM.swift
//  WeatherApp
//
//  Created by Prabhjot Singh Gogana on 26/6/2022.
//

import Foundation
import RxRelay
import RxSwift

struct DetailOfWeatherVM {
    var weatherListDetail$ = BehaviorRelay<WeatherList?>(value: nil)
    let isRequestComplete$: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    let error$ : PublishSubject<WeatherNetworkError> = PublishSubject()
    let disposable = DisposeBag()
    
    
    func requestWeatherDetailData() {
        self.isRequestComplete$.accept(true)

        APIManager<WeatherList>.requestData(requestURL: .detail(weatherListDetail$.value?.id ?? 0), method: .get, parameters: nil) { (result) in
            // just putting the delay so that can check the waiting time
            switch result {
            case .success(let object):
                self.weatherListDetail$.accept(object)
                self.isRequestComplete$.accept(false)
            case .failure(let failure) :
                self.isRequestComplete$.accept(false)
                switch failure {
                case .connectionError:
                    self.error$.onNext(.internetError("Check your Internet connection."))
                case .authorizationError:
                    self.error$.onNext(.serverMessage("Server Error"))
                default:
                    self.error$.onNext(.serverMessage("Unknown Error"))
                }
            }
        }
    }
}
