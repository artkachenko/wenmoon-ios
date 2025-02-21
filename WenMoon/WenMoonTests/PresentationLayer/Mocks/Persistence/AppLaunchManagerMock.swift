//
//  AppLaunchManagerMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation
@testable import WenMoon

class AppLaunchManagerMock: AppLaunchManager {
    var isFirstLaunch = true
    
    func reset() {
        isFirstLaunch = false
    }
}
