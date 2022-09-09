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
        
        expect(sut, completeWithError: .connectivity, when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorONon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500].enumerated()
        samples.forEach { index, statusCode in
            expect(sut, completeWithError: .invalidData, when: {
                client.complete(withStatusCode: statusCode, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWithError: .invalidData, when: {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (RemoteSpotLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteSpotLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteSpotLoader, completeWithError error: RemoteSpotLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedError = [RemoteSpotLoader.Error]()
        sut.load { capturedError.append($0) }
        
        action()
        
        XCTAssertEqual(capturedError, [error], file: file, line: line)
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
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: URL(string: "https://any-url.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completions(.success((data, response)))
        }
    }
}
