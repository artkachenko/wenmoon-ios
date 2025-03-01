//
//  NewsViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 01.03.25.
//

import XCTest
@testable import WenMoon

class NewsViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: NewsViewModel!
    var newsService: NewsServiceMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        newsService = NewsServiceMock()
        viewModel = NewsViewModel(newsService: newsService)
    }
    
    override func tearDown() {
        viewModel = nil
        newsService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchAllNews_success() async {
        // Setup
        let allNews = NewsFactoryMock.makeAllNews()
        newsService.getNewsResult = .success(allNews)
        
        // Action
        await viewModel.fetchAllNews()
        
        // Assertions
        let mappedNews = [
            allNews.coindesk,
            allNews.cointelegraph,
            allNews.cryptopotato,
            allNews.bitcoinmagazine,
            allNews.bitcoinist
        ]
            .compactMap { $0 }
            .flatMap { $0 }
            .sorted(by: { $0.date > $1.date })
        XCTAssertEqual(viewModel.news, mappedNews)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAllNews_usingCache() async {
        // Setup
        let cachedNews = [News(title: "Cached News", description: "Test", date: Date())]
        newsService.getNewsResult = .success(NewsFactoryMock.makeAllNews())
        viewModel.newsCache = cachedNews
        
        // Action
        await viewModel.fetchAllNews()
        
        // Assertions
        XCTAssertEqual(viewModel.news, cachedNews)
    }
    
    func testFetchAllNews_failure() async {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        newsService.getNewsResult = .failure(error)
        
        // Action
        await viewModel.fetchAllNews()
        
        // Assertions
        XCTAssertTrue(viewModel.news.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testExtractSource_validURL() {
        // Setup
        let url = URL(string: "https://coindesk.com/article")!
        let expectedSource = "Coindesk"
        
        // Action
        let source = viewModel.extractSource(from: url)
        
        // Assertions
        XCTAssertEqual(source, expectedSource)
    }
    
    func testExtractSource_invalidURL() {
        // Setup
        let unknownURL = URL(string: "https://unknown.com/article")!
        let malformedURL = URL(string: "https://com")!
        let nilURL: URL? = nil
        
        // Action
        let unknownSource = viewModel.extractSource(from: unknownURL)
        let malformedSource = viewModel.extractSource(from: malformedURL)
        let nilSource = viewModel.extractSource(from: nilURL)
        
        // Assertions
        XCTAssertNil(unknownSource)
        XCTAssertNil(malformedSource)
        XCTAssertNil(nilSource)
    }
}
