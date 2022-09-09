// Copyright @ 2022 Fernando Vega. All rights reserved.

import XCTest
import SpotAFireFeed

class RemoteSpotLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnHTTPClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorONon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        
        samples.forEach { index, statusCode in
            expect(sut, completeWith: .failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: statusCode, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoSpotsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        var capturedResult = [RemoteSpotLoader.Result]()
        sut.load { capturedResult.append($0) }
        
        let emptyListJSON = Data("[]".utf8)
        client.complete(withStatusCode: 200, data: emptyListJSON)

        XCTAssertEqual(capturedResult, [.success([])])
    }
    
    func test_load_deliversSpotItemsOn200HTTPResponseWithValidJSONList() {
        let (sut, client) = makeSUT()

        let spot1 = makeItem(id: UUID().uuidString,
                             author: "an author",
                             description: nil,
                             likes: 1,
                             image: URL(string: "https://a-url.com")!)
        
        let spot2 = makeItem(id: UUID().uuidString,
                             author: "another author",
                             description: "a description",
                             likes: 2,
                             image: URL(string: "https://another-url.com")!)
        
        expect(sut, completeWith: .success([spot1.model, spot2.model]), when: {
            let json = makeItemsJSON([spot1.json, spot2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteSpotLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSpotLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeItem(id: String, author: String, description: String? = nil, likes: Int, image: URL) -> (model: Spot, json: [String: Any]) {
        let item = Spot(id: id, author: author, description: description, likes: likes, image: image)
        let json = [
            "id": id,
            "username": author,
            "description": description as Any,
            "likes": likes,
            "thumb": image.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ spotsJSON: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: spotsJSON)
    }
    
    private func expect(_ sut: RemoteSpotLoader, completeWith result: RemoteSpotLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteSpotLoader.Result]()
        sut.load { capturedResult.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completions: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completions(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: URL(string: "https://any-url.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completions(.success((data, response)))
        }
    }
}
