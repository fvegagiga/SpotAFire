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
