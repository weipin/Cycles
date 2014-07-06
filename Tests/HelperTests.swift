//
//  HelperTests.swift
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

class HelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParseContentTypeLikeHeaderShouldWork() {
        var (type, parameters) = ParseContentTypeLikeHeader("text/html; charset=UTF-8")
        XCTAssertEqualObjects(type, "text/html");
        XCTAssertEqualObjects(parameters["charset"], "UTF-8");

        (type, parameters) = ParseContentTypeLikeHeader("text/html; charset=\"UTF-8\"")
        XCTAssertEqualObjects(type, "text/html");
        XCTAssertEqualObjects(parameters["charset"], "UTF-8");

        (type, parameters) = ParseContentTypeLikeHeader("text/html; charset='UTF-8'")
        XCTAssertEqualObjects(type, "text/html");
        XCTAssertEqualObjects(parameters["charset"], "UTF-8");
    }

    func testFormencodeDictionaryShouldWork() {
        var dict = ["k1": ["v1"], "k2": ["&;", "hello"], "k3": ["world"]]
        var str = FormencodeDictionary(dict)
        XCTAssertEqualObjects(str, "k1=v1&k2=%26%3B&k2=hello&k3=world")
    }

    func testParseURLWithQueryParametersShouldWork() {
        var (base, parameters) = ParseURLWithQueryParameters("http://mydomain.com?k1=v1&k1=v11&k2=v2")
        XCTAssertEqualObjects(base, "http://mydomain.com")
        XCTAssertEqualObjects(FormencodeDictionary(parameters), "k1=v1&k1=v11&k2=v2")

        (base, parameters) = ParseURLWithQueryParameters("k1=v1&k1=v11&k2=v2")
        XCTAssertFalse(base)
        XCTAssertEqualObjects(FormencodeDictionary(parameters), "k1=v1&k1=v11&k2=v2")

        (base, parameters) = ParseURLWithQueryParameters("http://mydomain.com")
        XCTAssertEqualObjects(base, "http://mydomain.com")
        XCTAssertEqualObjects(FormencodeDictionary(parameters), "")
    }

    func testMergeParametersToURLShouldWork() {
        var URL = MergeParametersToURL("http://domain.com?k1=v1&K2=v2", ["k3": ["v3"]]);
        XCTAssertEqualObjects(URL, "http://domain.com?k1=v1&k2=v2&k3=v3")

        // keys in both URL and parameters ("k1")
        URL = MergeParametersToURL("http://domain.com?k1=v1&K2=v2", ["k3": ["v3"], "k1": ["v11"]]);
        XCTAssertEqualObjects(URL, "http://domain.com?k1=v1&k1=v11&k2=v2&k3=v3")

        // escapsed characters
        URL = MergeParametersToURL("http://domain.com?k1=Content-Type%3Atext", ["k1": ["v1"]]);
        XCTAssertEqualObjects(URL, "http://domain.com?k1=Content-Type%3Atext&k1=v1")
    }
}
