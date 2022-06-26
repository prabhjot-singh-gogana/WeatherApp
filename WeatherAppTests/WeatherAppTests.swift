//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Prabhjot Singh Gogana on 19/6/2022.
//

import XCTest
@testable import WeatherApp

class WeatherAppTests: XCTestCase {

    //working
    let json = ["id": 13213, "name": "abc", "dt": 2342] as [String : Any]
    //failed
    //    let json = ["":""]
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJSON() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let json = try? JSONSerialization.data(withJSONObject: self.json, options: .prettyPrinted)
        XCTAssertNotNil(json)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decodedObject = try? decoder.decode(WeatherList.self, from: json!)
        XCTAssertNotNil(decodedObject)
        XCTAssert(decodedObject?.id == 13213)
        XCTAssert(decodedObject?.name == "abc")
        XCTAssert(decodedObject?.dt == 2342)
        
    }
    
    func testNetworkAPI() {
        let expectation = self.expectation(description: "Valid_Request")
        APIManager<Response>.requestData(requestURL: .list, method: .get, parameters: nil, completion: { (result) in
            XCTAssertNotNil(result)
            switch result {
            case .success(let object):
                XCTAssertNotNil(object)
                XCTAssertNotNil(object.list)
                XCTAssertNotNil(object.calctime)
                expectation.fulfill()
            case .failure(let failure) :
                switch failure {
                case .connectionError:
                    XCTFail("Check your Internet connection.")
                case .authorizationError:
                    XCTFail("Server Error")
                default:
                    XCTFail("Unknown Error")
                }
            }
        })
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
