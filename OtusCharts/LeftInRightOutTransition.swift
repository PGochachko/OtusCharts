//
//  LeftInRightOutTransition.swift
//  OtusCharts
//
//  Created by user on 16.01.2020.
//  Copyright © 2020 user. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var leftInRightOut: AnyTransition {
        let insertion = AnyTransition.move(edge:.leading)
            .combined(with: .opacity)
        let removal = AnyTransition.move(edge:.trailing)
            .combined(with: .opacity)
        return .asymmetric(insertion: insertion, removal: removal)
    }
}
