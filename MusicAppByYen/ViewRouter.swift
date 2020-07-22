//
//  ViewRouter.swift
//  FirstAppByYen
//
//  Created by YenChang on 2020/7/5.
//  Copyright © 2020 YenChang. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ViewRouter: ObservableObject {
    
    let objectWillChange = PassthroughSubject<ViewRouter, Never>()
    
    var currentPage = 1 {
        // do something after the currentPage change
        didSet {
            withAnimation() {
                objectWillChange.send(self)
            }
        }
    }
}


