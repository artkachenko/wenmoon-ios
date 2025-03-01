//
//  NewsViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import Foundation

final class NewsViewModel: BaseViewModel {
    // MARK: - Properties
    private let newsService: NewsService
    
    @Published private(set) var news: [News] = []
    
    var newsCache: [News] = []
    
    private let sourceMapping: [String: String] = [
        "coindesk.com": "Coindesk",
        "cointelegraph.com": "Cointelegraph",
        "coincu.com": "Coincu",
        "cryptopotato.com": "Cryptopotato",
        "bitcoinmagazine.com": "Bitcoin Magazine",
        "bitcoinist.com": "Bitcoinist"
    ]
    
    // MARK: - Initializers
    convenience init() {
        self.init(newsService: NewsServiceImpl())
    }
    
    init(newsService: NewsService) {
        self.newsService = newsService
        super.init()
        
        startCacheTimer(interval: 180) { [weak self] in
            self?.clearNewsCache()
        }
    }
    
    // MARK: - Interface
    @MainActor
    func fetchAllNews() async {
        isLoading = true
        defer { isLoading = false }
        
        if !newsCache.isEmpty {
            news = newsCache
            return
        }
        
        do {
            let allNews = try await newsService.getAllNews()
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
            self.news = mappedNews
            newsCache = mappedNews
        } catch {
            setError(error)
        }
    }
    
    func extractSource(from url: URL?) -> String? {
        guard let url, let host = url.host else {
            return nil
        }
        
        let hostParts = host.split(separator: ".")
        if hostParts.count >= 2 {
            let domain = hostParts.suffix(2).joined(separator: ".")
            return sourceMapping[domain]
        }
        return nil
    }
    
    // MARK: - Helpers
    private func clearNewsCache() {
        if !newsCache.isEmpty {
            newsCache.removeAll()
            print("All News cache cleared")
        }
    }
}
