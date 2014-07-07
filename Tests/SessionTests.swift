//
//  SessionTests.swift
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


class SessionTests: XCTestCase {
    class DummySessionDelegateNoneRetry : SessionDelegate {
        func sessionShouldRetryCycle(session: Session, cycle: Cycle, error: NSError?) -> Bool {
            return false
        }
    }
    class DummySessionDelegateNoneStatusFailure : SessionDelegate {
        func sessionShouldTreatStatusCodeAsFailure(session: Session, status: Int) -> Bool {
            return false
        }
    }
    let DelegateNoneRetry = DummySessionDelegateNoneRetry()
    let DelegateNoneStatusFailure = DummySessionDelegateNoneStatusFailure()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDelegateForRetryShouldWork() {
        var URL = tu_("echo?code=500")
        var cycle = Cycle(requestURL: URL)
        cycle.solicited = true
        cycle.session.delegate = DelegateNoneRetry
        var finished = false

        cycle.start {(cycle, error) in
            XCTAssertNotNil(error)
            finished = true
        }
        println("\(cycle.session.delegate)")
        WaitForWithTimeout(2.0) {
            return finished
        }
        println("\(cycle.retriedCount)")
        XCTAssertTrue(cycle.retriedCount == 0);
    }

    func testDelegateForStatusFailureShouldWork() {
        var expection = self.expectationWithDescription("")
        var URL = tu_("echo?code=400")
        var cycle = Cycle(requestURL: URL)
        cycle.session.delegate = DelegateNoneStatusFailure
        cycle.start { (cycle, error) in
            XCTAssertNil(error)
            expection.fulfill()
        }
        self.waitForExpectationsWithTimeout(Timeout, handler: nil)
    }
}

