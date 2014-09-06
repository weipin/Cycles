//
//  ValueTransformer.swift
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

import Foundation


@objc (ISO8601DateTransformer)
public class ISO8601DateTransformer: NSValueTransformer {
    lazy var transformDataFormatter = { () -> NSDateFormatter in
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter
    }()

    lazy var reverseTransformDataFormatter = { () -> NSDateFormatter in
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        return formatter
    }()

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }

    override public func transformedValue(value: AnyObject!) -> AnyObject? {
        var str = value as? String
        if str == nil {
            println("ISO8601Date transforming failed")
            return nil
        }

        var date = self.transformDataFormatter.dateFromString(str!)
        
        return date
    }

    override public func reverseTransformedValue(value: AnyObject!) -> AnyObject? {
        var date = value as? NSDate
        if date == nil {
            println("ISO8601Date reverse transforming failed")
            return nil
        }

        var str = self.reverseTransformDataFormatter.stringFromDate(date!)
        return str
    }
}

@objc (ObjectTransformer)
public class ObjectTransformer: NSValueTransformer {
    public class func dataForMapping() -> AnyObject {
        return NSMutableDictionary()
    }

    // must override
    public class func objectForMapping() -> AnyObject {
        assert(false)
        return []
    }

    // must override
    public class func mappingMeta() -> ObjectMappingMeta {
        assert(false)
        return ObjectMappingMeta(dict: Dictionary<String, AnyObject>())
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }

    override public func transformedValue(value: AnyObject!) -> AnyObject? {
        let object: AnyObject = self.dynamicType.objectForMapping()
        let meta = self.dynamicType.mappingMeta()
        updateObject(object, fromData: value, withMeta: meta)

        return object
    }

    override public func reverseTransformedValue(value: AnyObject!) -> AnyObject? {
        let meta = self.dynamicType.mappingMeta()
        let data: AnyObject = self.dynamicType.dataForMapping()
        updateData(data, fromObject: value, withMeta: meta)

        return data
    }
}

@objc (ObjectListTransformer)
public class ObjectListTransformer: NSValueTransformer {
    public class func dataForMapping() -> AnyObject {
        return NSMutableDictionary()
    }

    // must override
    public class func objectForMapping() -> AnyObject {
        assert(false)
        return []
    }

    // must override
    public class func mappingMeta() -> ObjectMappingMeta {
        assert(false)
        return ObjectMappingMeta(dict: Dictionary<String, AnyObject>())
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }

    override public func transformedValue(value: AnyObject!) -> AnyObject? {
        if let ary = value as? [AnyObject] {
            let meta = self.dynamicType.mappingMeta()
            var result = [AnyObject]()
            for i in ary {
                let object: AnyObject = self.dynamicType.objectForMapping()
                updateObject(object, fromData: i, withMeta: meta)
                result.append(object)
            }

            return result
        }

        return nil
    }

    public override func reverseTransformedValue(value: AnyObject!) -> AnyObject? {
        if let ary = value as? [AnyObject] {
            let meta = self.dynamicType.mappingMeta()
            var result = [AnyObject]()
            for i in ary {
                let data: AnyObject = self.dynamicType.dataForMapping()
                updateData(data, fromObject: i, withMeta: meta)
                result.append(data)
            }

            return result
        }

        return nil
    }
}
