//
//  URITemplateTests.swift
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

import UIKit
import XCTest

import CyclesTouch

class URITemplateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testURLTemplate() {
        var bundle = NSBundle(identifier: TestBundleIdentifier)
        var URL = bundle.URLForResource("URITemplateRFCTests", withExtension: "json")
        var data = NSData.dataWithContentsOfURL(URL!, options: NSDataReadingOptions(0), error: nil)
        var dict: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: nil) as NSDictionary
        for (testSuiteName, value) in dict {
            var variables = value["values"]
            var testcases = value["testcases"] as [AnyObject]
            for testcase in testcases {
                var template = testcase[0] as String
                var result = testcase[1] as String
                var str = ExpandURITemplate(template, values: variables)
                XCTAssertEqual(str, result, "SUITE: \(testSuiteName), TEMPLATE: \(template)")
            }
        }
    }
}
