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

func FormencodeDictionary(dict: Dictionary<String, String[]>) -> String {
    var result = String[]()
    var keys = Array(dict.keys)
    keys = sort(keys) {(s1: String, s2: String) -> Bool in
        return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedAscending
    }

    for (let k, v) in dict {
        var sorted = sort(v) {(s1: String, s2: String) -> Bool in
            return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedAscending
        }
        for i in sorted {
            var escaped = EscapeStringToURLArgumentString(i)
            result.append("\(k)=\(escaped)")
        }
    }

    return result.bridgeToObjectiveC().componentsJoinedByString("&")
}

func ParseURLWithQueryParameters(URLString: String) -> (URL: String?,
parameters: Dictionary<String, String[]>) {
    var base: String?
    var query: String
    var parameters = Dictionary<String, String[]>()
    if let loc = find(URLString, "?") {
        base = URLString[URLString.startIndex..loc]
        query = URLString[advance(loc, 1)..URLString.endIndex]
    } else {
        query = URLString
    }
    var set = NSCharacterSet(charactersInString: "&;")
    var ary = query.componentsSeparatedByCharactersInSet(set)
    for str in ary {
        if let loc = find(str, "=") {
            var k = str[str.startIndex..loc]
            if countElements(k) == 0 {
                continue
            }
            k = k.lowercaseString
            var v = str[advance(loc, 1)..str.endIndex]
            if var values = parameters[k] {
                values.append(v)
                parameters[k] = values
            } else {
                parameters[k] = [v]
            }
        }
    }

    if !base && parameters.count == 0 {
        base = URLString
    }
    return (base, parameters)
}

func MergeParametersToURL(URLString: String, parameters: Dictionary<String, String[]>) -> String {
    var (base, existing_params) = ParseURLWithQueryParameters(URLString)
    for (var k, var v) in parameters {
        k = k.lowercaseString
        if var values = existing_params[k] {
            values.extend(v)
            existing_params[k] = values
        } else {
            existing_params[k] = v
        }
    }

    let query = FormencodeDictionary(existing_params)
    var ary = String[]()
    if base {
        ary.append(base!)
    }
    if !query.isEmpty {
        ary.append(query)
    }
    return ary.bridgeToObjectiveC().componentsJoinedByString("?")
}

