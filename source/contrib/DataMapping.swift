//
//  DataMapping.swift
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

enum DataMappingKey: String {
    case ClassName = "ClassName"
    case Items = "Items"
    case Key = "Key"
    case Path = "Path"
    case Transformer = "Transformer"
}

class DataMapping {
    func objectByMappingSource(source: AnyObject, meta: Dictionary<String, AnyObject>) -> AnyObject? {
        var value: AnyObject? = meta[DataMappingKey.Items.toRaw()]
        if value == nil {
            println("items not found")
            assert(false)
            return nil
        }

        let items = value as? [Dictionary<String, AnyObject>]
        if items == nil {
            println("invalid items type")
            assert(false)
            return nil
        }

        var result: AnyObject = Dictionary<String, AnyObject>()
        value = meta[DataMappingKey.ClassName.toRaw()]
        if value == nil {
            println("class name not found")
            assert(false)
            return nil
        }
        if let className = (value as? String) {
            if let C = NSClassFromString(className) as? NSObject.Type {
                result = C()
            } else {
                println("invalid class name \(className)")
                assert(false)
                return nil
            }
        } else {
            println("invalid class name")
            assert(false)
            return nil
        }

        for item in items! {
            // key
            value = meta[DataMappingKey.Key.toRaw()]
            if value == nil {
                println("key not found")
                assert(false)
                continue
            }
            let key = value as? String
            if key == nil {
                println("invalid key")
                assert(false)
                continue
            }

            // value path
            value = meta[DataMappingKey.Path.toRaw()]
            if value == nil {
                println("value path not found")
                assert(false)
                continue
            }
            let path = value as? String
            if path == nil {
                println("invalid value path")
                assert(false)
                continue
            }

            // transformer
            var transformer: NSValueTransformer?
            value = meta[DataMappingKey.Transformer.toRaw()]
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

            value = source.valueForKeyPath(path)
            if value == nil {
                println("value not found at path \(path)")
                continue
            }
            var newValue: AnyObject? = value
            if transformer != nil {
                newValue = transformer!.transformedValue(value)
                if newValue == nil {
                    println("value transforming failed for key \(key)")
                    continue
                }
            }

            result.setValue(newValue, forKey: key)
        } // for item

        return result
    }
}