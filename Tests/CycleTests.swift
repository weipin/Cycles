//
//  CycleTests.swift
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

let Timeout = 20.0

func URLByAppendingPathComponent(lastComponent: String) -> NSURL {
    let base = "http://127.0.0.1:8000/test/"
    var str = base + lastComponent
    var URL = NSURL(string: str)

    return URL
}

class CycleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGETShouldWork() {
        var expection = self.expectationWithDescription("get")
        var URL = URLByAppendingPathComponent("hello")
        var cycle = Cycle(requestURL: URL)

        cycle.start {(cycle: Cycle, error: NSError?) in
            XCTAssertFalse(error)
            XCTAssertEqualObjects(cycle.response.text, "Hello World");
            XCTAssertEqual(cycle.response!.statusCode!, 200);
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testGETTextEncodingFromHeaderShouldWork() {
        var expection = self.expectationWithDescription("get")
        var URL = URLByAppendingPathComponent("echo?header=Content-Type%3Atext%2Fhtml%3B%20charset%3Dgb2312")
        var cycle = Cycle(requestURL: URL)

        cycle.start {(cycle: Cycle, error: NSError?) in
            XCTAssertFalse(error)

            var enc = CFStringEncoding(CFStringEncodings.EUC_CN.toRaw())
            var encoding = cycle.response.textEncoding
            XCTAssertTrue(encoding == CFStringConvertEncodingToNSStringEncoding(enc));
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testGetTextEncodingWhenContentTypeContainsTextAndCharsetIsMissingShouldWork() {
        var expection = self.expectationWithDescription("get")
        var URL = URLByAppendingPathComponent("echo?header=Content-Type%3Atext%2Fhtml")
        var cycle = Cycle(requestURL: URL)

        cycle.start {(cycle: Cycle, error: NSError?) in
            XCTAssertFalse(error)

            var enc = CFStringEncoding(CFStringBuiltInEncodings.ISOLatin1.toRaw())
            var encoding = cycle.response.textEncoding
            XCTAssertTrue(encoding == CFStringConvertEncodingToNSStringEncoding(enc));
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testGetTextEncodingWithDetectionShouldWork() {
        var expection = self.expectationWithDescription("get")
        var URL = URLByAppendingPathComponent("echo?header=Content-Type%3AXXXXXXX&content=%E4%BD%A0%E5%A5%BD&encoding=gb2312")
        var cycle = Cycle(requestURL: URL)

        cycle.start {(cycle: Cycle, error: NSError?) in
            XCTAssertFalse(error)

            var enc = CFStringEncoding(CFStringEncodings.GB_18030_2000.toRaw())
            var encoding = cycle.response.textEncoding
            XCTAssertTrue(encoding == CFStringConvertEncodingToNSStringEncoding(enc));
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testGetTextEncodingWithLastFallBackShouldWork() {
        var expection = self.expectationWithDescription("get")
        var URL = URLByAppendingPathComponent("echo?header=Content-Type%3AXXXXXXX")
        var cycle = Cycle(requestURL: URL)

        cycle.start {(cycle: Cycle, error: NSError?) in
            XCTAssertFalse(error)

            var encoding = cycle.response.textEncoding
            XCTAssertTrue(encoding == NSUTF8StringEncoding);
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }


    func testUploadDataShouldWork() {
        var data = "Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var expection = self.expectationWithDescription("post")
        var URL = URLByAppendingPathComponent("dumpupload/")
        var cycle = Cycle(requestURL: URL, taskType: .Upload, requestMethod: "POST")
        cycle.dataToUpload = data

        cycle.start {(cycle: Cycle, error: NSError?) in
            XCTAssertFalse(error)

            XCTAssertEqualObjects(cycle.response.text, "Hello World")
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }
}

