//
//  NewsService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 28.02.25.
//

import Foundation

protocol NewsService {
    func getAllNews() async throws -> AllNews
}

final class NewsServiceImpl: BaseBackendService, NewsService {
    // MARK: - NewsService
    func getAllNews() async throws -> AllNews {
        do {
            let data = try await httpClient.get(path: "all-news")
            return try decoder.decode(AllNews.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
}
