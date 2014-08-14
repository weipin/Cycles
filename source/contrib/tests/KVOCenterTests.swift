//
//  KVOCenterTests.swift
//
//  Copyright (c) 2014 Weipin Xia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import XCTest

import CyclesTouch

class KVOCenterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddObserverShouldWork() {
        var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
        var lastName: AnyObject?
        var expection = self.expectationWithDescription("")
        KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
        options: .New, context: nil, observed:dict, queue: NSOperationQueue.mainQueue()) {
            keyPath, observed, change, context in
            lastName = change[NSKeyValueChangeNewKey]
            expection.fulfill()
        }
        dict.setValue("last2", forKey: "lastName")
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
        var result = lastName as String
        XCTAssertEqual(result, "last2")
    }

    func testAddObserverWithDefaultParameterShouldWork() {
        var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
        var lastName: AnyObject?
        var expection = self.expectationWithDescription("")
        KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
            observed:dict, callback: {
                keyPath, observed, change, context in
                lastName = change[NSKeyValueChangeNewKey]
                expection.fulfill()
        })
        dict.setValue("last2", forKey: "lastName")
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
        var result = lastName as String
        XCTAssertEqual(result, "last2")
    }

    func testRemoveObserverShouldWork() {
        var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
        var lastName: AnyObject?
        KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
            observed:dict, callback: {
                keyPath, observed, change, context in
                lastName = change[NSKeyValueChangeNewKey]
        })
        KeyValueObservingCenter.sharedInstance.removeObserver(self, keyPath: "lastName")
        dict.setValue("last2", forKey: "lastName")
        WaitForWithTimeout(1) {
            return false
        }
        XCTAssertTrue(lastName == nil)
    }

    func testRemoveObserverThroughProxyShouldWork() {
        var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
        var lastName: AnyObject?
        var proxy = KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
            observed:dict, callback: {
                keyPath, observed, change, context in
                lastName = change[NSKeyValueChangeNewKey]
        })
        KeyValueObservingCenter.sharedInstance.removeObserver(proxy)
        dict.setValue("last2", forKey: "lastName")
        WaitForWithTimeout(1) {
            return false
        }
        XCTAssertTrue(lastName == nil)
    }

    func testRemoveObserverWithNilPathShouldWork() {
        var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
        var lastName: AnyObject?
        KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
            observed:dict, callback: {
                keyPath, observed, change, context in
                lastName = change[NSKeyValueChangeNewKey]
        })
        KeyValueObservingCenter.sharedInstance.removeObserver(self, keyPath: nil, observed: dict)
        dict.setValue("last2", forKey: "lastName")
        WaitForWithTimeout(1) {
            return false
        }
        XCTAssertTrue(lastName == nil)
    }

    func testRemoveObserverWithNilObservedShouldWork() {
        var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
        var lastName: AnyObject?
        KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
            observed:dict, callback: {
                keyPath, observed, change, context in
                lastName = change[NSKeyValueChangeNewKey]
        })
        KeyValueObservingCenter.sharedInstance.removeObserver(self, keyPath: "lastName", observed: nil)
        dict.setValue("last2", forKey: "lastName")
        WaitForWithTimeout(1) {
            return false
        }
        XCTAssertTrue(lastName == nil)
    }
}
