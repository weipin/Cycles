//
//  ServiceTests.swift
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

class FooTestService: Service {
    override class func className() -> String {
        return "FooTestService"
    }

    override func defaultSession() -> Session {
        return Session()
    }

    override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
    }

}

class ServiceBasicTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testURLStringByJoiningComponentsShouldWork() {
        var result = Service.URLStringByJoiningComponents("part1", part2: "part2")
        XCTAssertEqual(result, "part1/part2")

        result = Service.URLStringByJoiningComponents("", part2: "part2")
        XCTAssertEqual(result, "part2")

        result = Service.URLStringByJoiningComponents("part1", part2: "")
        XCTAssertEqual(result, "part1")

        result = Service.URLStringByJoiningComponents("part1/", part2: "part2")
        XCTAssertEqual(result, "part1/part2")

        result = Service.URLStringByJoiningComponents("part1/", part2: "/part2")
        XCTAssertEqual(result, "part1/part2")

        result = Service.URLStringByJoiningComponents("part1/", part2: "")
        XCTAssertEqual(result, "part1/")
    }

    func testVerifyProfileShouldWork() {
        var bundle = NSBundle(identifier: TestBundleIdentifier)
        var URL = bundle.URLForResource("FooTestService", withExtension: "plist")
        var service = FooTestService()
        XCTAssertTrue(service.updateProfileFromLocalFile(URL: URL))
        XCTAssertTrue(service.verifyProfile(service.profile))
    }

    func testVerifyProfileShouldFailForDuplicateName() {
        var bundle = NSBundle(identifier: TestBundleIdentifier)
        var URL = bundle.URLForResource("FooTestService_DuplicateName", withExtension: "plist")
        var service = FooTestService()
        XCTAssertTrue(service.updateProfileFromLocalFile(URL: URL))
        XCTAssertFalse(service.verifyProfile(service.profile))
    }

    func testVerifyProfileShouldFailForNameNotFound() {
        var bundle = NSBundle(identifier: TestBundleIdentifier)
        var URL = bundle.URLForResource("FooTestService_NameNotFound", withExtension: "plist")
        var service = FooTestService()
        XCTAssertTrue(service.updateProfileFromLocalFile(URL: URL))
        XCTAssertFalse(service.verifyProfile(service.profile))
    }

    func testVerifyProfileShouldFailForNoResources() {
        var bundle = NSBundle(identifier: TestBundleIdentifier)
        var URL = bundle.URLForResource("FooTestService_NoResources", withExtension: "plist")
        var service = FooTestService()
        XCTAssertTrue(service.updateProfileFromLocalFile(URL: URL))
        XCTAssertFalse(service.verifyProfile(service.profile))
    }

    func testVerifyProfileShouldFailForURITemplateNotFound() {
        var bundle = NSBundle(identifier: TestBundleIdentifier)
        var URL = bundle.URLForResource("FooTestService_URITemplateNotFound", withExtension: "plist")
        var service = FooTestService()
        XCTAssertTrue(service.updateProfileFromLocalFile(URL: URL))
        XCTAssertFalse(service.verifyProfile(service.profile))
    }
}

class ServiceHTTPTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCycleForResourceWithIdentiferShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestService()
        var cycle = service.cycleForResourceWithIdentifer("hello",
            URIValues: ["content": "hello world"])
        cycle.start {(cycle, error) in
            XCTAssertFalse(error)
            XCTAssertEqual(cycle.response.text, "hello world");
            XCTAssertEqual(cycle.response!.statusCode!, 200);
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testCycleForResourceWithIdentiferReplaceShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestService()
        var cycle1 = service.cycleForResourceWithIdentifer("delay", identifier: "test_task",
            URIValues: ["delay": 2, "content": "hello 1"])
        cycle1.start {(cycle, error) in
            XCTAssertTrue(false) // should never reach here
        }
        // wait until cycle1 started
        WaitForWithTimeout(100.0) {
            return cycle1.core !== nil
        }

        var cycle2 = service.cycleForResourceWithIdentifer("delay", identifier: "test_task",
            option: .Replace, URIValues: ["delay": 0, "content": "hello 2"])
        XCTAssertFalse(cycle1 === cycle2)
        cycle2.start {(cycle, error) in
            XCTAssertFalse(error)
            XCTAssertEqual(cycle.response.text, "hello 2");
            XCTAssertEqual(cycle.response!.statusCode!, 200);
            expection.fulfill()
        }

        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testCycleForResourceWithIdentiferReuseShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestService()
        var cycle1 = service.cycleForResourceWithIdentifer("delay", identifier: "test_task",
            URIValues: ["delay": 2, "content": "hello 1"])
        cycle1.start {(cycle, error) in
            XCTAssertTrue(false) // should never reach here
        }
        // wait until cycle1 started
        WaitForWithTimeout(100.0) {
            return cycle1.core !== nil
        }

        var cycle2 = service.cycleForResourceWithIdentifer("delay", identifier: "test_task",
            option: .Reuse, URIValues: ["delay": 0, "content": "hello 2"])
        XCTAssertTrue(cycle1 === cycle2)
        cycle2.start {(cycle, error) in
            XCTAssertFalse(error)
            XCTAssertEqual(cycle.response.text, "hello 1");
            XCTAssertEqual(cycle.response!.statusCode!, 200);
            expection.fulfill()
        }

        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testCycleForResourceShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestService()
        var cycle = service.cycleForResource("hello", URIValues: ["content": "hello world"])
        cycle.start {(cycle, error) in
            XCTAssertFalse(error)
            XCTAssertEqual(cycle.response.text, "hello world");
            XCTAssertEqual(cycle.response!.statusCode!, 200);
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testRequestResourceWithIdentiferShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestService()
        var cycle = service.requestResourceWithIdentifer("hello", identifier: "test_task",
            URIValues: ["content": "hello world"], completionHandler: {(cycle, error) in
                XCTAssertFalse(error)
                XCTAssertEqual(cycle.response.text, "hello world");
                XCTAssertEqual(cycle.response!.statusCode!, 200);
                expection.fulfill()
            })
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testRequestResourceShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestService()
        var cycle = service.requestResource("hello",
            URIValues: ["content": "hello world"], completionHandler: {(cycle, error) in
                XCTAssertFalse(error)
                XCTAssertEqual(cycle.response.text, "hello world");
                XCTAssertEqual(cycle.response!.statusCode!, 200);
                expection.fulfill()
            })
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }
}

class FooTestMoreService: Service {
    override class func className() -> String {
        return "FooTestMoreService"
    }

    override func defaultSession() -> Session {
        var session = super.defaultSession()
        session.requestProcessors = [JSONProcessor()]
        session.responseProcessors = [JSONProcessor()]

        return session
    }

    override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
        if name == "postdata" {
            cycle.requestProcessors = [DataProcessor()]
            cycle.responseProcessors = []
        }
    }
    
}

class ServiceHTTPMoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRequestResourceByPOSTingJSONShouldWork() {
        var expection = self.expectationWithDescription("")
        var service = FooTestMoreService()
        service.requestResource("postjson", requestObject: ["k1": "v1"],
            completionHandler: { (cycle, error) in
                XCTAssertFalse(error)
                var dict = cycle.response.object as Dictionary<String, String>
                XCTAssertEqual(dict["k1"]!, "v1")
                expection.fulfill()
            })
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }

    func testRequestResourceByPOSTingDataShouldWork() {
        var data = "hello world".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var expection = self.expectationWithDescription("")
        var service = FooTestMoreService()
        service.requestResource("postdata", requestObject: data,
            completionHandler: { (cycle, error) in
                XCTAssertFalse(error)
                XCTAssertEqual(cycle.response.text, "hello world")
                expection.fulfill()
            })
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }
}