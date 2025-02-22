//
//  AppLaunchProviderMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation
@testable import WenMoon

class AppLaunchProviderMock: AppLaunchProvider {
    var isFirstLaunch = true
    
    func reset() {
        isFirstLaunch = false
    }
}
