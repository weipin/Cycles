//
//  ObjectMapping.swift
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

enum ObjectMappingKey: String {
    case Items = "Items"
    case Key = "Key"
    case Path = "Path"
    case Transformer = "Transformer"
}

public class ObjectMappingItem {
    var dict: Dictionary<String, AnyObject>!

    var key: String {
        get {
            var key: String!
            let value: AnyObject? = self.dict[ObjectMappingKey.Key.rawValue]
            if value != nil {
                key = value as? String
                if key == nil {
                    println("invalid key")
                    assert(false)
                }

            } else {
                println("key not found")
                assert(false)
            }

            return key
        }
    }

    var path: String {
        get {
            var path: String!
            let value: AnyObject? = self.dict[ObjectMappingKey.Path.rawValue]
            if value != nil {
                path = value as? String
                if path == nil {
                    println("invalid value path")
                    assert(false)
                }

            } else {
                println("value path not found")
                assert(false)
            }

            return path
        }
    }

    var transformer: NSValueTransformer {
        get {
            var transformer: NSValueTransformer?
            let value: AnyObject? = self.dict[ObjectMappingKey.Transformer.rawValue]
            if value != nil {
                if let transformerName = value as? String {
                    transformer = NSValueTransformer(forName: transformerName)
                    if transformer == nil {
                        if let C = NSClassFromString(transformerName) as? NSValueTransformer.Type {
                            transformer = C()
                        }
                    }
                }
            }
            assert(transformer != nil)
            return transformer!
        }
    }

    init(dict: Dictionary<String, AnyObject>) {
        self.dict = dict
    }

}

public class ObjectMappingMeta {
    var dict: Dictionary<String, AnyObject>!

    public class func metaForName(name: String, bundle: NSBundle? = nil) -> ObjectMappingMeta? {
        let b = bundle ?? NSBundle.mainBundle()
        var URL = b.URLForResource(name, withExtension: "plist")
        if URL == nil {
            URL = b.URLForResource(name, withExtension: nil)
        }
        if URL == nil {
            println("mapping meta not found for name \(name)");
            return nil
        }

        var error: NSError?
        let data: NSData! = NSData(contentsOfURL: URL!, options: NSDataReadingOptions(0), error: &error)
        if (data == nil) {
            println("read mapping meta failed for URL \(URL)");
            return nil
        }

        var dict = NSPropertyListSerialization.propertyListWithData(data,
                        options: 0, format: nil, error: &error) as Dictionary<String, AnyObject>?
        if dict == nil {
            println("load mapping meta failed for URL \(URL)")
        }

        let meta = ObjectMappingMeta(dict: dict!)
        return meta
    }

    public var items: [ObjectMappingItem] {
        get {
            var value: AnyObject? = self.dict[ObjectMappingKey.Items.rawValue]
            if value == nil {
                println("items not found")
                assert(false)
                return []
            }

            let ary = value as? [Dictionary<String, AnyObject>]
            if ary == nil {
                println("invalid items type")
                assert(false)
                return []
            }

            var result = ary!.map { (var dict) -> ObjectMappingItem in
                return ObjectMappingItem(dict: dict)
            }
            return result
        }
    }

    init(dict: Dictionary<String, AnyObject>) {
        self.dict = dict
    }

}

public func updateObject(object:AnyObject, fromData data: AnyObject, withMeta meta: ObjectMappingMeta) {
    let items = meta.items
    for item in items {
        var value: AnyObject! = data.valueForKeyPath(item.path)
        if value == nil {
            println("value not found in data for path \(item.path)")
            continue
        }
        var newValue: AnyObject! = item.transformer.transformedValue(value)
        if newValue == nil {
            println("value transforming failed for key \(item.key)")
            continue
        }

        object.setValue(newValue, forKey: item.key)
    }
}

public func updateData(data: AnyObject, fromObject object: AnyObject, withMeta meta: ObjectMappingMeta) {
    let items = meta.items
    for item in items {
        var value: AnyObject! = object.valueForKey(item.key)
        if value == nil {
            println("value not found in object for key \(item.key)")
            continue
        }
        var newValue: AnyObject! = item.transformer.reverseTransformedValue(value)
        if newValue == nil {
            println("value reverse transforming failed for key \(item.key)")
            continue
        }

        data.setValue(newValue, forKeyPath: item.path)
    }
}

