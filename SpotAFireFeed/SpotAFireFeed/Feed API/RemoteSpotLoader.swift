// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

public final class RemoteSpotLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[Spot], Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                if let spots = try? SpotMapper.map(data, response) {
                    completion(.success(spots))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class SpotMapper {
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
