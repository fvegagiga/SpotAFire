// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

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
                if response.statusCode == 200,
                   let spots = try? JSONDecoder().decode([SpotItem].self, from: data) {
                    completion(.success(spots.map { $0.spot }))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

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
