//
//  DetailOfWeatherVC.swift
//  WeatherApp
//
//  Created by Prabhjot Singh Gogana on 26/6/2022.
//

import UIKit
import RxSwift
import RxCocoa

class DetailOfWeatherVC: UIViewController {
    @IBOutlet weak var lblMinTemp: UILabel!
    @IBOutlet weak var lblMaxTemp: UILabel!
    @IBOutlet weak var lblWeather: UILabel!
    @IBOutlet weak var txtDetail: UITextView!
    var detailOfWeatherVM = DetailOfWeatherVM()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindUI()
        self.initialSetupUI()
        // Do any additional setup after loading the view.
    }
    
    func initialSetupUI() {
        self.title = self.detailOfWeatherVM.weatherListDetail$.value?.name
        self.lblWeather.text = self.detailOfWeatherVM.weatherListDetail$.value?.weather?.first?.weatherDescription
        self.lblMinTemp.text = "MinTemp. - \(self.detailOfWeatherVM.weatherListDetail$.value?.main?.tempMin ?? 0)"
        self.lblMaxTemp.text = "MaxTemp. - \(self.detailOfWeatherVM.weatherListDetail$.value?.main?.tempMax ?? 0)"
    }

    func bindUI() {
        // binding loading to vc
        self.detailOfWeatherVM.isRequestComplete$
            .observe(on: MainScheduler.instance).subscribe { isLoading in
                isLoading == true ? print("Request Start"): print("Request Ends")
            }.disposed(by: self.disposeBag)
        
        
        // observing errors to show
        self.detailOfWeatherVM
            .error$
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (error) in
                switch error {
                case .internetError(let message):
                    print("Error - \(message)")
                case .serverMessage(let message):
                    print("Warning - \(message)")
                }
            })
            .disposed(by: disposeBag)
        
        // binding details values
        self.detailOfWeatherVM.weatherListDetail$.compactMap({String(describing: $0)}).bind(to: self.txtDetail.rx.text).disposed(by: self.detailOfWeatherVM.disposable)
    }
    
}
