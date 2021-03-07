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
