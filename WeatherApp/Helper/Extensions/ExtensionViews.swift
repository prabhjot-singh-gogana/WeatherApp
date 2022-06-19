//
//  ExtensionViews.swift
//  NewsDemoMVVM
//
//  Created by Prabhjot Singh Gogana on 14/3/22.
//

import UIKit

// protocol created to not use extra parameters for identifier

protocol ReusableIdentifier: AnyObject {
    static var reusableIdentifier: String { get }
    static var nibObject: UINib? { get }
}

extension ReusableIdentifier {
    static var reusableIdentifier: String { return String(describing: Self.self) }
    static var nibObject: UINib? { return UINib(nibName: String(describing: Self.self), bundle: nil) }
}
extension UITableView {

    func preferredContentSizeOfTable() -> CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
    
    // for registering the table with generics
    func registerReusableIDCell<T: UITableViewCell>(_: T.Type) where T: ReusableIdentifier {
        if let nib = T.nibObject {
            self.register(nib, forCellReuseIdentifier: T.reusableIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reusableIdentifier)
        }
    }

    func dequeueReusableIDCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: ReusableIdentifier {
        return self.dequeueReusableCell(withIdentifier: T.reusableIdentifier, for: indexPath) as! T
    }
    
    static func initCell<T: UITableViewCell>() -> T where T: ReusableIdentifier {
        return UITableViewCell.init(style: .default, reuseIdentifier: T.reusableIdentifier) as! T
    }

    func registerReusableIDHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReusableIdentifier {
        if let nib = T.nibObject {
            self.register(nib, forHeaderFooterViewReuseIdentifier: T.reusableIdentifier)
        } else {
            self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reusableIdentifier)
        }
    }

    func dequeueReusableIDHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? where T: ReusableIdentifier {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reusableIdentifier) as! T?
    }
}

// ------------- Tab Bar Controller --------------//

extension UITabBarController {
    func findController<T: UIViewController>() -> T? {
        for controller in self.viewControllers! {
            if let controller = controller as? T {
                return controller
            } else {
                continue
            }
        }
        return nil
    }
}

public extension UIImageView {
    // used for caching the images
    
    func loadImage(fromURL url: String) {
        guard let imageURL = URL(string: url) else {
            return
        }
        
        let cache =  URLCache.shared
        let request = URLRequest(url: imageURL)
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.transition(toImage: image)
                }
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        DispatchQueue.main.async {
                            self.transition(toImage: image)
                        }
                    }
                }).resume()
            }
        }
    }
    
    func transition(toImage image: UIImage?) {
        UIView.transition(with: self, duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.image = image
        },
                          completion: nil)
    }
}
