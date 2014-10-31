//
//  Helper.swift
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

/*!
 * Same as NSLocalizedString. The difference is that this function uses table
 * "Cycles", not the default one ("Localizable.strings").
 */
public func LocalizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: "Cycles", comment: "")
}

/*!
 * @abstract 
 * Parse a Content-Type like string (e.g. "text/html; charset=UTF-8"). 
 *
 * @param header 
 * The Content-Type like string to parse
 *
 * @result (type, parameters)
 * type
 * The Content-Type part of the string, or nil if not available.
 * parameters
 * The dictionary of parsed pairs (the part after character ';').
 */
public func ParseContentTypeLikeHeader(header: String) -> (type: String?,
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
                var k = str[str.startIndex..<loc]
                k = k.stringByTrimmingCharactersInSet(wset)
                if k.isEmpty {
                    continue
                }
                var v = str[advance(loc, 1)..<str.endIndex]
                v = v.stringByTrimmingCharactersInSet(wset)
                v = v.stringByTrimmingCharactersInSet(qset)
                parameters[k.lowercaseString] = v
            }
        }
    }

    return (type, parameters)
}

/*!
 * @abstract 
 * Escape a string to be a URL argument (RFC 3986).
 *
 * @param str 
 * The string to escape
 *
 * @result
 * Escaped string
 */
public func EscapeStringToURLArgumentString(str: String) -> String {
    var s = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                    str as NSString, nil,
                                                    "!*'();:@&=+$,/?%#[]",
                                                    CFStringBuiltInEncodings.UTF8.rawValue) as NSString
    return s
}

/*!
 * @abstract 
 * Unescape a URL argument (RFC 3986).
 *
 * @param str 
 * The URL argument to unescape
 *
 * @result 
 * Unescaped version of the URL argument
 */
public func UnescapeStringFromURLArgumentString(str: String) -> String {
    var range = NSRange(location: 0, length:countElements(str))
    var s = str as NSString
    s = s.stringByReplacingOccurrencesOfString("+", withString: " ",
                                               options: NSStringCompareOptions.LiteralSearch,
                                               range: range)
    s = s.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? ""
    return s
}

/*!
 * @discussion 
 * Join the keys and values in a dictioanry to a "form-urlencoded"
 * string. The key is separated from the value by `=' and key/value pairs are
 * separated from each other by `&'. The value will be escaped before it joins the
 * string. The order of the pairs in the joined string is sorted.
 *
 * The keys MUST be String and the values MUST be an array of String.
 *
 * @param dict 
 * The dictionary to provide the key/value pairs.
 *
 * @result 
 * "form-urlencoded" string of the dictionary.
 */
public func FormencodeDictionary(dict: Dictionary<String, [String]>) -> String {
    var result = [String]()
    var keys = Array(dict.keys)
    keys = sorted(keys) {(s1: String, s2: String) -> Bool in
        return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedAscending
    }

    for k in keys {
        var v = sorted(dict[k]!) {(s1: String, s2: String) -> Bool in
            return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedAscending
        }
        for i in v {
            var escaped = EscapeStringToURLArgumentString(i)
            result.append("\(k)=\(escaped)")
        }
    }

    return (result as NSArray).componentsJoinedByString("&")
}

/*!
 * @abstract 
 * Parse an URL string for query parameters.
 *
 * @param 
 * URLString The URL string to parse
 *
 * @result (URL, parameters)
 * URL 
 * the none query part of the URL.
 * parameters 
 * A dictionary contains the parameter pairs.
 */
public func ParseURLWithQueryParameters(URLString: String) -> (URL: String?,
parameters: Dictionary<String, [String]>) {
    var base: String?
    var query: String
    var parameters = Dictionary<String, [String]>()
    if let loc = find(URLString, "?") {
        base = URLString[URLString.startIndex..<loc]
        query = URLString[advance(loc, 1)..<URLString.endIndex]
    } else {
        query = URLString
    }
    var set = NSCharacterSet(charactersInString: "&;")
    var ary = query.componentsSeparatedByCharactersInSet(set)
    for str in ary {
        if let loc = find(str, "=") {
            var k = str[str.startIndex..<loc]
            if k.isEmpty {
                continue
            }
            k = k.lowercaseString
            var v = str[advance(loc, 1)..<str.endIndex]
            v = UnescapeStringFromURLArgumentString(v)
            if var values = parameters[k] {
                values.append(v)
                parameters[k] = values
            } else {
                parameters[k] = [v]
            }
        }
    }

    if base == nil && parameters.count == 0 {
        base = URLString
    }
    return (base, parameters)
}

/*!
 * @discussion 
 * Join the keys and values in a dictionary to a "form-urlencoded" string
 * and merge the result a specified URL. Duplicate keys appear in the URL and
 * parameters will be merged properly.
 *
 * @param URLString 
 * The URL that parameters will be merged to, can also contain its own query string.

 * @param parameters 
 * The key/value pairs in this dictionary will be merged to the URL.
 *
 * @result 
 * A new URL with query merged from URL and parameters.
 */
public func MergeParametersToURL(URLString: String, parameters: Dictionary<String, [String]>) -> String {
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
    var ary = [String]()
    if base != nil {
        ary.append(base!)
    }
    if !query.isEmpty {
        ary.append(query)
    }
    return (ary as NSArray).componentsJoinedByString("?")
}

