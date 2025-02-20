//
//  FearAndGreedIndex.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 19.02.25.
//

import Foundation

struct FearAndGreedIndex: Codable {
    struct FearAndGreedData: Codable {
        let value: String
        let valueClassification: String
    }
    
    let data: [FearAndGreedData]
}
