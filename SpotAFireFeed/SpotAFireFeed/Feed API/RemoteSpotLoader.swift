// Copyright @ 2022 Fernando Vega. All rights reserved.

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteSpotLoader {
    let url: URL
    let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}
