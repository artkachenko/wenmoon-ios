//
//  News.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 28.02.25.
//

import Foundation

struct News: Identifiable, Codable, Hashable {
    // MARK: - Properties
    let title: String?
    let description: String?
    let thumbnail: URL?
    let url: URL?
    let date: Date
    
    var id: String {
        url?.absoluteString ?? UUID().uuidString
    }
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case thumbnail
        case url
        case date
    }
    
    // MARK: - Initializers
    init(
        title: String? = nil,
        description: String? = nil,
        thumbnail: URL? = nil,
        url: URL? = nil,
        date: Date = .init()
    ) {
        self.title = title
        self.description = description
        self.thumbnail = thumbnail
        self.url = url
        self.date = date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        thumbnail = try container.decodeIfPresent(SafeURL.self, forKey: .thumbnail)?.url
        url = try container.decodeIfPresent(SafeURL.self, forKey: .url)?.url
        
        if let dateString = try container.decodeIfPresent(String.self, forKey: .date) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            self.date = dateFormatter.date(from: dateString) ?? Date()
        } else {
            self.date = Date()
        }
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(url, forKey: .url)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = dateFormatter.string(from: date)
        try container.encode(dateString, forKey: .date)
    }
}
