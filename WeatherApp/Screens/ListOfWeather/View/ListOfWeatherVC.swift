//
//  ListOfWeatherVC.swift
//  WeatherApp
//
//  Created by Prabhjot Singh Gogana on 19/6/2022.
//

import UIKit
import RxCocoa
import RxSwift
import SkeletonView

class ListOfWeatherVC: UIViewController {
    private let disposeBag = DisposeBag()
    var weatherListVM = WeatherListVM()
    @IBOutlet weak var tblViewWeatherList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
    
    func initialSetup() {
        navigationItem.title = "Weather List"
        bindUI()
        self.weatherListVM.requestWeatherData()
    }
    
    private func bindUI() {
        //uitableView Binding
        self.bindTableView()
        
        // binding loading to vc
        self.weatherListVM.loading
            .filter({$0==true})
            .observe(on: MainScheduler.instance).subscribe { isLoading in
                self.weatherListVM.weatherList$.accept(self.weatherListVM.emptyWeatherList)
            }.disposed(by: disposeBag)
        
        
        // observing errors to show
        self.weatherListVM
            .error
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
    }
    
    //binding the tableview datasource
    func bindTableView() {
        // binding the table with items
        let strCellIndentifier = String(describing: CellForWeatherList.self)
        self.weatherListVM.weatherList$.compactMap({$0}).bind(to: self.tblViewWeatherList.rx.items(cellIdentifier: strCellIndentifier, cellType: CellForWeatherList.self)) { index, element, cell in
            if self.weatherListVM.loading.value == true {
                cell.showGradientSkeleton()
            } else {
                cell.hideSkeleton()
                cell.updateTheCell(with: element)
            }
        }.disposed(by: self.disposeBag)
        
        //        selection of row
        self.tblViewWeatherList.rx.modelSelected(WeatherList.self)
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { (weatherList) in
                //whole object here to show all the news on next screen
                print(weatherList)
            }).disposed(by: self.disposeBag)
    }
}
    
