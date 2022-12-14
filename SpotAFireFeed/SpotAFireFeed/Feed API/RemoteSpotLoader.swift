// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

public final class RemoteSpotLoader: SpotLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = SpotLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(SpotMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    

}
