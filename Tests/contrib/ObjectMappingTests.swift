//
//  ObjectMappingTests.swift
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

class FooModel: Model {
    var date: NSDate {
        get {
            return self.dict["Date"] as NSDate
        }

        set {
            self.dict["Date"] = newValue
        }
    }
}

@objc (FooTransformer)
class FooTransformer: ObjectTransformer {
    // must override
    override class func objectForMapping() -> AnyObject {
        return FooModel(dict: Dictionary<String, AnyObject>())
    }

    // must override
    override class func mappingMeta() -> ObjectMappingMeta {
        return ObjectMappingMeta.metaForName("FooModel")!
    }
}

@objc (FooListTransformer)
class FooListTransformer: ObjectListTransformer {
    override class func objectForMapping() -> AnyObject {
        return FooModel(dict: Dictionary<String, AnyObject>())
    }

    override class func mappingMeta() -> ObjectMappingMeta {
        return ObjectMappingMeta.metaForName("FooModel")!
    }
}

class ObjectMappingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFieldMappingShouldWork() {
        var meta = ObjectMappingMeta.metaForName("FooModel")
        var data = ["Date": "2014-05-28T08:35:37"]
        var object = NSMutableDictionary()
        updateObject(object, fromData: data, withMeta: meta!)
        let date = object.valueForKey("date") as NSDate
        XCTAssertNotNil(date)

        var dict = NSMutableDictionary()
        updateData(dict, fromObject: object, withMeta: meta!)
        let str = dict.valueForKey("Date") as String
        XCTAssertEqual(str, "2014-05-28T08:35:37")
    }

    func testObjectMappingShouldWork() {
        var meta = ObjectMappingMeta.metaForName("ContainerModel")
        var data = ["Foo": ["Date": "2014-05-28T08:35:37"]]
        var object = NSMutableDictionary()
        updateObject(object, fromData: data, withMeta: meta!)
        let foo = object.valueForKey("foo") as FooModel
        XCTAssertNotNil(foo)

        var dict = NSMutableDictionary()
        updateData(dict, fromObject: object, withMeta: meta!)
        let str = dict.valueForKeyPath("Foo.Date") as String
        XCTAssertEqual(str, "2014-05-28T08:35:37")
    }

    func testObjectListMappingShouldWork() {
        var meta = ObjectMappingMeta.metaForName("ContainerModel")
        var data = ["FooList": [["Date": "2014-05-28T08:35:37"], ["Date": "2014-05-29T01:31:31"]]]
        var object = NSMutableDictionary()
        updateObject(object, fromData: data, withMeta: meta!)
        let fooList = object.valueForKey("fooList") as [FooModel]
        XCTAssertNotNil(fooList)
        XCTAssertEqual(fooList.count, 2)

        var dict = NSMutableDictionary()
        updateData(dict, fromObject: object, withMeta: meta!)
        let list = dict.valueForKeyPath("FooList") as [AnyObject]
        XCTAssertEqual(list.count, 2)
        let str1 = list[0].valueForKey("Date") as String
        XCTAssertEqual(str1, "2014-05-28T08:35:37")
        let str2 = list[1].valueForKey("Date") as String
        XCTAssertEqual(str2, "2014-05-29T01:31:31")

    }
}
