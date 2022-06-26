//
//  PSRefresher.swift
//  NewsDemoMVVM
//
//  Created by Prabhjot Singh Gogana on 16/3/22.
//

import RxSwift
import RxCocoa
import Foundation
import UIKit

class PSRefresher: NSObject {
    let refresh = PublishSubject<Void>()
    let refreshControl = UIRefreshControl()
    
    init(view: UIScrollView) {
        super.init()
        view.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshControlDidRefresh(_: )), for: .valueChanged)
    }
    
    // MARK: - Action
    
    @objc func refreshControlDidRefresh(_ control: UIRefreshControl) {
        refresh.onNext(())
    }
    
    func end() {
        refreshControl.endRefreshing()
    }
}
