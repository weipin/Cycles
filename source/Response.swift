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

/*!
 * This class represents a HTTP response.
 */
public class Response {
/*!
 * The NSHTTPURLResponse represents the primary response information.
 */
    public var core: NSHTTPURLResponse?

/*!
 * The object represents the response data. It will be created by the
 * Processor objects from response data.
 */
    public var object: AnyObject?

/*!
 * The NSData of the received HTTP response body.
 */
    public var data: NSMutableData = NSMutableData()

/*!
 * The NSDate stores the time the response is received.
 */
    public var timestamp: NSDate?

/*!
 * The default encoding for converting request data to text.
 */
    public var textReadEncoding: NSStringEncoding?

/*!
 * The encoding of the response data.
 */
    public lazy var textEncoding: NSStringEncoding = {
        return TextProcessor.textEncodingFromResponse(self)
    }()

    public lazy var text: String? = {
        var encoding = self.textReadEncoding
        if encoding == nil {
            encoding = self.textEncoding
        }
        if encoding == nil {
            encoding = NSUTF8StringEncoding
        }
        return NSString(data: self.data, encoding: encoding!);
    }()

/*!
 * @abstract 
 * The status code of the response.
 */
    public var statusCode: Int? {
        return self.core?.statusCode
    }

/*!
 * @abstract The NSDictionary contains the response headers.
 */
    public var headers: NSDictionary? {
        return self.core?.allHeaderFields
    }

    init() {

    }

/*!
 * @abstract 
 * Get value for a specified header. The search is case-insensitive.
 *
 * @param header 
 * The String represents the header to get the value of. It's case-insensitive.
 *
 * @result 
 * The value of the header, or nil if none is found.
 */
    public func valueForHTTPHeaderField(header: String) -> String? {
        var result: String? = nil
        if self.headers == nil {
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
    
/*!
 * @abstract 
 * Append a specified NSData to the data property.
 *
 * @param data
 * The NSData to be appended to the data property.
 */
    public func appendData(data: NSData) {
        self.data.appendData(data)
    }
}

