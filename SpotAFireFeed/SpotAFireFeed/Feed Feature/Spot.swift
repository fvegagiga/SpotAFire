// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

public struct Spot: Equatable {
    public let id: String
    public let author: String
    public let description: String?
    public let likes: Int
    public let image: URL
    
    public init(id: String, author: String, description: String?, likes: Int, image: URL) {
        self.id = id
        self.author = author
        self.description = description
        self.likes = likes
        self.image = image
    }
}

extension Spot: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case author = "username"
        case description
        case likes
        case image = "thumb"
    }
}
