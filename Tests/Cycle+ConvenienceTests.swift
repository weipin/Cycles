//
//  Cycle+ConvenienceTests.swift
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


class CycleConvenienceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGETShouldWork() {
        var expection = self.expectationWithDescription("")
        var URLString = t_("hello")
        Cycle.get(URLString, completionHandler: {(cycle, error) in
            XCTAssertNil(error)
            XCTAssertEqual(cycle.response.text, "Hello World");
            XCTAssertEqual(cycle.response!.statusCode!, 200);
            expection.fulfill()
        })

        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testGETWithParametersShouldWork() {
        var expection = self.expectationWithDescription("")
        var URLString = t_("echo")
        Cycle.get(URLString, parameters: ["content": ["helloworld"]],
                  completionHandler: {(cycle, error) in
                    XCTAssertNil(error)
                    XCTAssertEqual(cycle.response.text, "helloworld");
                    XCTAssertEqual(cycle.response!.statusCode!, 200);
                    expection.fulfill()
            })

        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testPOSTShouldWork() {
        var expection = self.expectationWithDescription("")
        var URLStrng = t_("dumpupload/")
        var requestObject = NSDictionary(object: "v1", forKey: "k1")
        Cycle.post(URLStrng, requestObject: requestObject,
                   requestProcessors: [JSONProcessor()],
                   responseProcessors: [JSONProcessor()],
                   completionHandler: {(cycle, error) in
                        XCTAssertNil(error)
                        var dict = cycle.response.object as? NSDictionary
                        XCTAssertNotNil(dict)
                        var value = dict!.objectForKey("k1") as? String
                        XCTAssertNotNil(value)
                        XCTAssertEqual(value!, "v1")
                        expection.fulfill()
                })

        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testUploadShouldWork() {
        var data = "Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var expection = self.expectationWithDescription("")
        var URLString = t_("dumpupload/")
        Cycle.upload(URLString, data: data!, completionHandler: {
            (cycle, error) in
            XCTAssertNil(error)

            XCTAssertEqual(cycle.response.text, "Hello World")
            expection.fulfill()
        })
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testDownloadShouldWork() {
        var expection = self.expectationWithDescription("")
        var URLString = t_("echo?content=helloworld")
        Cycle.download(URLString,
            downloadFileHandler: {(cycle, location) in
                XCTAssertNotNil(location)
                var content = NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding, error: nil)
                XCTAssertEqual(content, "helloworld")
            },
            completionHandler: {(cycle, error) in
                XCTAssertNil(error)
                expection.fulfill()
            })
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }
}

