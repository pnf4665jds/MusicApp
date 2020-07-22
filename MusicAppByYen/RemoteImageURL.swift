//
//  RemoteImageURL.swift
//  FirstAppByYen
//
//  Created by YenChang on 2020/7/13.
//  Copyright © 2020 YenChang. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class RemoteImageURL: ObservableObject {
    struct ImageData {
        var image: UIImage
        var isSet: Bool
    }
    
    var didChange = PassthroughSubject<UIImage, Never>()
    @Published var uiImages = Array<ImageData>()
    
    // set uiImages array with url
    func setImageWithURL(imageURL: String, index: Int){
        if index >= self.uiImages.count {
            uiImages.append(ImageData(image: UIImage(imageLiteralResourceName: "Gray"), isSet: false))
        }
        
        guard let url = URL(string: imageURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in guard let data = data else { return }
            DispatchQueue.main.async {
                self.uiImages[index].image = UIImage(data: data)!
                self.uiImages[index].isSet = true
            }
        }.resume()
    }
}
