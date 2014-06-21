//
//  Helper.swift
//  CyclesTouch
//
//  Created by Weipin Xia on 6/15/14.
//  Copyright (c) 2014 Cocoahope. All rights reserved.
//

import Foundation

func LocalizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: "Cycles", comment: "")
}

func ParseContentTypeLikeHeader(header: String) -> (type: String?,
    parameters: Dictionary<String, String>) {

    var ary = header.componentsSeparatedByString(";")
    var parameters = Dictionary<String, String>()
    var type: String?

    let wset = NSCharacterSet.whitespaceCharacterSet()
    let qset = NSCharacterSet(charactersInString: "\"'")
    for (index, object) in enumerate(ary) {
        let str = object as String
        if index == 0 {
            type = str.stringByTrimmingCharactersInSet(wset)

        } else {
            if let loc = find(str, "=") {
                var k = str[str.startIndex..loc]
                k = k.stringByTrimmingCharactersInSet(wset)
                if countElements(k) == 0 {
                    continue
                }
                var v = str[advance(loc, 1)..str.endIndex]
                v = v.stringByTrimmingCharactersInSet(wset)
                v = v.stringByTrimmingCharactersInSet(qset)
                parameters[k.lowercaseString] = v
            }
        }
    }

    return (type, parameters)
}

func EscapeStringToURLArgumentString(str: String) -> String {
    var s = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                    str.bridgeToObjectiveC(), nil,
                                                    "!*'();:@&=+$,/?%#[]",
                                                    CFStringBuiltInEncodings.UTF8.toRaw())
    return s
}

func UnescapeStringFromURLArgumentString(str: String) -> String {
    var range = NSRange(location: 0, length:countElements(str))
    var s = str as NSString
    s = s.stringByReplacingOccurrencesOfString("+", withString: " ",
                                               options: NSStringCompareOptions.LiteralSearch,
                                               range: range)
    s = s.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    return s
}

func FormencodeDictionary(dict: NSDictionary) -> String {
    var result = String[]()
    for (var k: AnyObject, v: AnyObject) in dict {
        var key = k as? NSString
        if !key {
            continue
        }

        if let value = v as? NSArray {
            for i : AnyObject in value {
                if let str = i as? NSString {
                    var escaped = EscapeStringToURLArgumentString(str)
                    result.append("\(key)=\(escaped)")
                }
            }
        } else if let value = v as? NSString {
            var escaped = EscapeStringToURLArgumentString(value)
            result.append("\(key)=\(escaped)")

        } else {

        }
    }

    return result.bridgeToObjectiveC().componentsJoinedByString("&")
}

