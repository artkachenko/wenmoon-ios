//
//  SafeURL.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 02.03.25.
//

import Foundation

struct SafeURL: Codable, Hashable {
    // MARK: - Properties
    let url: URL?
    
    // MARK: - Initializers
    init?(string: String) {
        url = Self.createURL(from: string)
    }
    
    // MARK: - Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let url = try? container.decode(URL.self) {
            self.url = url
        } else {
            let urlString = try container.decode(String.self)
            url = Self.createURL(from: urlString)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url?.absoluteString)
    }
    
    // MARK: - Helpers
    private static func createURL(from urlString: String) -> URL? {
        let trimmedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURLString.isEmpty else { return nil }
        if let url = URL(string: trimmedURLString) {
            return url
        }
        let escapedURLString = trimmedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: escapedURLString)
    }
}
