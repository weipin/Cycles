//
//  Processor.swift
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

import CoreFoundation
import Foundation

/*!
 * @discussion 
 * This class is an abstract class you use to update a Request or a Response. 
 * Because it is abstract, you do not use this class directly but instead
 * subclass or use one of the existing subclasses. You create subclass to convert
 * data between request/response data and your specific object.
 */
public class Processor {
    public init() {

    }

/*!
 * @abstract 
 * Process the specified Request.
 *
 * @param request
 * The Request to process.
 *
 * @param error
 * Set if an error occurs.
 *
 * @result 
 * true if processed, or false if an error occurs.
 */
    public func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        assert(false)
        return false
    }

/*!
 * @abstract 
 * Process the specified Response.
 *
 * @param response
 * The Response to process.
 *
 * @param error
 * Set if an error occurs.
 *
 * @result The updated Response.
 */
    public func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        assert(false)
        return false
    }
}

/*!
 * @discussion 
 * This class add Basic Authentication header to the Request.
 */
public class BasicAuthProcessor : Processor {
    var username: String
    var password: String

    public convenience override init() {
        self.init(username: "", password: "")
    }

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public class func headerForUsernamePassword(username: String, password: String) -> String {
        var str = "\(username):\(password)"
        if let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
            str = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
        } else {
            NSLog("base64 encoding failed for Basic Authentication header");
        }

        return "Basic \(str)"
    }

    public override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        var header = BasicAuthProcessor.headerForUsernamePassword(self.username,
                        password: self.password)
        request.core.setValue(header, forHTTPHeaderField: "Authorization")
        return true
    }

    public override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        assert(false)
        return false
    }
}

/*!
 * @discussion 
 * This class does nothing but assigns objects between variables. For request, 
 * it assigns your object to the request data, so you need to ensure that your 
 * object is a NSData. For response, it assigns the response data to your object.
 */
public class DataProcessor : Processor {
    public override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? NSData {
            request.data = object

        } else {
            if error != nil {
                error.memory = NSError(domain: CycleErrorDomain,
                    code: CycleErrorCode.ObjectKindNotMatch.rawValue,
                    userInfo: nil)
            }
            return false
        }

        return true
    }

    public override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        response.object = response.data
        return true
    }
}

/*!
 * @discussion 
 * This class converts your String to request data. Or converts the response 
 * data to String. There is less chance you will need to use this class because 
 * Response has built-in support for the its text and the encoding. Use this
 * class if you want to process the content in a specified queue.
 */

public class TextProcessor : Processor {
/*!
 * @discussion 
 * The encoding to use when converts your NSString to request data.
 */
    var writeEncoding: NSStringEncoding = NSUTF8StringEncoding

/*!
 * @discussion 
 * The encoding to use when converts request data to your String. If you don't 
 * specify a value, the encoding will be guessed.
 */
    var readEncoding: NSStringEncoding?

/*!
 * @discussion 
 * The encoding of the response data, determined by examining the response.
 */
    var textEncoding: NSStringEncoding?

/*!
 * @discussion
 * Determine the text encoding by examining the response.
 */
    class func textEncodingFromResponse(response: Response) -> NSStringEncoding {
        var contentType = response.valueForHTTPHeaderField("content-type")
        var charset: String?

        // Try charset in the header
        if contentType != nil {
            let (type, parameters) = ParseContentTypeLikeHeader(contentType!)
            charset = parameters["charset"]
            if type != nil && charset != nil {
                var enc = CFStringConvertIANACharSetNameToEncoding(charset! as NSString)
                if enc != kCFStringEncodingInvalidId {
                    return CFStringConvertEncodingToNSStringEncoding(enc)
                }
            }
        }

        // Defaults to "ISO-8859-1" if there is no charset in header and 
        // Content-Type contains "text" (RFC 2616, 3.7.1)
        if charset == nil && contentType != nil {
            if (contentType! as NSString).containsString("text") {
                var enc = CFStringBuiltInEncodings.ISOLatin1.rawValue
                return CFStringConvertEncodingToNSStringEncoding(enc)
            }
        }

        // Make a guess
        return NSString.stringEncodingForData(response.data,
                                              encodingOptions: nil,
                                              convertedString: nil,
                                              usedLossyConversion: nil)
    }

    public override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? NSString {
            if let data = object.dataUsingEncoding(self.writeEncoding) {
                request.data = data
            } else {
                if (error != nil) {
                    error.memory = NSError(domain: NSCocoaErrorDomain,
                        code: NSFileWriteInapplicableStringEncodingError,
                        userInfo: nil)
                }
            }

        } else {
            if (error != nil) {
                error.memory = NSError(domain: CycleErrorDomain,
                    code: CycleErrorCode.ObjectKindNotMatch.rawValue,
                    userInfo: nil)
            }
        }

        return true
    }

    public override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        var encoding = self.readEncoding
        if encoding != nil {
            encoding = TextProcessor.textEncodingFromResponse(response)
            if encoding != nil {
                response.textEncoding = encoding!
            }
        }
        if encoding == nil {
            encoding = NSUTF8StringEncoding
        }

        // TODO: How can we tell if the string creation fails?
        response.text = NSString(data: response.data, encoding: encoding!)
        return true
    }
}

/*!
 * @discussion
 * This class converts objects between your NSDictionary and request data with 
 * JSON format. For request, header "Content-Type: application/json" will be added.
 */
public class JSONProcessor : Processor {
    public override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object: AnyObject = request.object {
            var e: NSError?
            request.data = NSJSONSerialization.dataWithJSONObject(object, options: nil, error: &e)
            if (e != nil) {
                if (error != nil) {
                    error.memory = e
                }
                return false
            } else {
                request.core.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

        } else {
            if (error != nil) {
                error.memory = NSError(domain: CycleErrorDomain,
                    code: CycleErrorCode.ObjectKindNotMatch.rawValue,
                    userInfo: nil)
            }
            return false
        }

        return true
    }

    public override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        var e: NSError?
        response.object = NSJSONSerialization.JSONObjectWithData(response.data,
                                                                 options: .AllowFragments,
                                                                 error: &e)
        if e != nil {
            if (error != nil) {
                error.memory = e
            }
            return false
        }
        return true
    }

}

/*!
 * @discussion 
 * This class converts your NSDictionary to a form encoded string as request 
 * body. Header "Content-Type: application/x-www-form-urlencoded" will be added.
 */
public class FORMProcessor : Processor {
    public override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? Dictionary<String, [String]> {
            request.object = FormencodeDictionary(object)
            request.core.setValue("application/x-www-form-urlencoded",
                                  forHTTPHeaderField: "Content-Type")

        } else {
            if (error != nil) {
                error.memory = NSError(domain: CycleErrorDomain,
                    code: CycleErrorCode.ObjectKindNotMatch.rawValue,
                    userInfo: nil)
            }
            return false
        }

        return true
    }

    public override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        assert(false)
        return false
    }
}
