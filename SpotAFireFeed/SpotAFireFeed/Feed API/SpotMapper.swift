// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

class SpotMapper {
    private struct SpotItem: Decodable {
        let id: String
        let username: String
        let description: String?
        let likes: Int
        let thumb: URL

        var spot: Spot {
            Spot(id: id, author: username, description: description, likes: likes, image: thumb)
        }
    }
    
    static var OK_200: Int { return 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [Spot] {
        guard response.statusCode == OK_200 else {
            throw RemoteSpotLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode([SpotItem].self, from: data)
        return root.map { $0.spot }
    }
}
