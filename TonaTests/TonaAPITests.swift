import XCTest
@testable import Tona

class TonaAPITests: XCTestCase {
    var tonaAPI: TonaAPI!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        tonaAPI = TonaAPI(baseURL: "https://mock.api.tona.app", session: mockSession)
    }
    
    override func tearDown() {
        tonaAPI = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testUploadFirstGroupSuccess() async {
        // Configure Mock Response
        let mockResponse = UploadGroupResponse(success: true, message: nil, groupId: "mockGroupId")
        URLProtocolMock.requestHandler = { request in
            guard let url = request.url, url.absoluteString == "https://mock.api.tona.app/api/v1/upload/first-group" else {
                throw TonaAPIError.invalidURL
            }
            
            let data = try JSONEncoder().encode(mockResponse)
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        do {
            let response = try await tonaAPI.uploadFirstGroup(images: [UIImage()])
            XCTAssertEqual(response.groupId, "mockGroupId")
            XCTAssertTrue(response.success)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // ... other test functions
}

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
