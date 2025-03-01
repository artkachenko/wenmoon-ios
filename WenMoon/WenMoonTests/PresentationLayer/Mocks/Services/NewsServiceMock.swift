//
//  NewsServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 01.03.25.
//

import XCTest
@testable import WenMoon

class NewsServiceMock: NewsService {
    // MARK: - Properties
    var getNewsResult: Result<AllNews, APIError>!
    
    // MARK: - CoinScannerService
    func getAllNews() async throws -> AllNews {
        switch getNewsResult {
        case .success(let news):
            return news
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getNewsResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
}
