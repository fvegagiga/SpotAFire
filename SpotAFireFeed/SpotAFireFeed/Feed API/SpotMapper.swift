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
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteSpotLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode([SpotItem].self, from: data) else {
            return .failure(.invalidData)
        }

        let spots = root.map { $0.spot }
        return .success(spots)
    }
}
