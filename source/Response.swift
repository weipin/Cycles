//
//  Response.swift
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

class Response {
    var core: NSHTTPURLResponse?
    var object: AnyObject?
    var data: NSMutableData = NSMutableData()
    var timestamp: NSDate?
    var textReadEncoding: NSStringEncoding?

    @lazy var textEncoding: NSStringEncoding? = {
        return TextProcessor.textEncodingFromResponse(self)
    }()

    @lazy var text: String? = {
        var encoding = self.textReadEncoding
        if !encoding {
            encoding = self.textEncoding
        }
        if !encoding {
            encoding = NSUTF8StringEncoding
        }
        return NSString(data: self.data, encoding: encoding!);
    }()

    var statusCode: Int? {
        return self.core?.statusCode
    }

    var headers: NSDictionary? {
        return self.core?.allHeaderFields
    }

    init() {

    }
    
    func valueForHTTPHeaderField(header: String) -> String? {
        var result: String? = nil
        if !self.headers {
            return nil
        }
        for (var k: AnyObject, v: AnyObject) in self.headers! {
            if (k as? String)?.caseInsensitiveCompare(header) == NSComparisonResult.OrderedSame {
                result = v as? String
                break
            }
        }
        return result
    }

    func appendData(data: NSData) {
        self.data.appendData(data)
    }
}

