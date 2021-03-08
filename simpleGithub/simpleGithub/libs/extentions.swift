//
//  extentions.swift
//  simpleGithub
//
//  Created by hasan milli on 7.03.2021.
//

import Foundation
import UIKit

extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: 32
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

extension UIImageView {
    func downloadFrom(_ url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image.roundedImage
            }
        }.resume()
    }
    func downloadFrom(_ strLink: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: strLink) else { return }
        downloadFrom( url, contentMode: mode)
    }
}


extension UIButton {
    func loadImageWithUrl(_ url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let img = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.setImage(img.roundedImage, for: .normal)
            }
        }.resume()
    }
    func loadImageWithUrlStr(_ strLink: String) {
        guard let url = URL(string: strLink) else { return }
        loadImageWithUrl(url)
    }
}

extension UINavigationController {
    func pop(transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.popViewController(animated: false)
    }

    func push(viewController vc: UIViewController, transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }

    private func addTransition(transitionType type: CATransitionType = .fade, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }
}

extension UIViewController {
    func showAlert(_ strHeader:String, strDetail:String)  {
        let alert = UIAlertController(title: strHeader, message: strDetail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
              switch action.style{
              case .default:
                break

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")


              @unknown default:
                fatalError()
              }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getDataWithStrUrl(_ strUrl:String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void ) {
        if let url = URL(string: strUrl) {
            let session = URLSession.shared
            let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)

            let task = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)
            task.resume()
            
        } else {
            completionHandler(nil,nil,nil)
        }
    }
}
