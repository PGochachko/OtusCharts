//
//  App.swift
//  OtusCharts
//
//  Created by user on 16.01.2020.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class App {
    static var instance = App()
    
    var mainWindow: UIWindow?
    var overlayWindow: UIWindow?
    
    private init() {}

    func hiddenOverlayWindow() {
        mainWindow?.makeKeyAndVisible()
        overlayWindow?.isHidden = true;
    }
}
