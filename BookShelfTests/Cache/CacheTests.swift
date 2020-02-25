//
//  CacheTests.swift
//  BookShelfTests
//
//  Created by Hyungsung Kim on 2020/02/23.
//  Copyright © 2020 cream. All rights reserved.
//

import XCTest
@testable import BookShelf

class CacheTests: XCTestCase {
    
    override func setUp() {
        DataCache.shared.async = false
    }

    override func tearDown() {
        
    }

    func testDataCache() {
        let testString = "test string"
        let testKey = "keyForTestString"
        
        DataCache.shared.setData(testString.data(using: .utf8)!, key: testKey)
        
        var testString2: String?
        DataCache.shared.getData(withKey: testKey) { data in
            if let data = data {
                testString2 = String(data: data, encoding: .utf8)
            }
        }
        
        XCTAssertEqual(testString, testString2, "캐시 저장 및 조회 실패")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
