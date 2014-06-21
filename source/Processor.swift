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

class Processor {
    func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        assert(false)
        return false
    }

    func processResponse(response: Response, error: NSErrorPointer) -> Bool? {
        assert(false)
        return false
    }

    init() {

    }
}

class DataProcessor : Processor {
    override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? NSData {
            request.data = object

        } else {
            error.memory = NSError(domain: CycleErrorDomain,
                                   code: CycleErrorCode.ObjectKindNotMatch.toRaw(),
                                   userInfo: nil)
            return false
        }

        return true
    }

    override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        response.object = response.data
        return true
    }
}

class TextProcessor : Processor {
    var writeEncoding: NSStringEncoding = NSUTF8StringEncoding
    var readEncoding: NSStringEncoding?
    var textEncoding: NSStringEncoding?

    class func textEncodingFromResponse(response: Response) -> NSStringEncoding? {
        var contentType = response.valueForHTTPHeaderField("content-type")
        var charset: String?

        // Try charset in the header
        if contentType {
            let (type, parameters) = ParseContentTypeLikeHeader(contentType!)
            charset = parameters["charset"]
            if type && charset {
                var enc = CFStringConvertIANACharSetNameToEncoding(charset!.bridgeToObjectiveC())
                if enc != kCFStringEncodingInvalidId {
                    return CFStringConvertEncodingToNSStringEncoding(enc)
                }
            }
        }

        // Defaults to "ISO-8859-1" if there is no charset in header and 
        // Content-Type contains "text" (RFC 2616, 3.7.1)
        if !charset && contentType {
            if contentType!.rangeOfString("text") {
                var enc = CFStringBuiltInEncodings.ISOLatin1.toRaw()
                return CFStringConvertEncodingToNSStringEncoding(enc)
            }
        }

        // Make a guess
        return NSString.stringEncodingForData(response.data,
                                              encodingOptions: nil,
                                              convertedString: nil,
                                              usedLossyConversion: nil)
    }

    override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? NSString {
            if let data = object.dataUsingEncoding(self.writeEncoding) {
                request.data = data
            } else {
                error.memory = NSError(domain: NSCocoaErrorDomain,
                    code: NSFileWriteInapplicableStringEncodingError,
                    userInfo: nil)
            }

        } else {
            error.memory = NSError(domain: CycleErrorDomain,
                code: CycleErrorCode.ObjectKindNotMatch.toRaw(),
                userInfo: nil)
        }

        return true
    }

    override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        var encoding = self.readEncoding
        if !encoding {
            encoding = TextProcessor.textEncodingFromResponse(response)
            if encoding {
                response.textEncoding = encoding!
            }
        }
        if !encoding {
            encoding = NSUTF8StringEncoding
        }

        // TODO: How can we tell if the string creating fails?
        response.text = NSString(data: response.data, encoding: encoding!)
        return true
    }
}

class JSONProcessor : Processor {
    override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? NSDictionary {
            var e: NSError?
            request.data = NSJSONSerialization.dataWithJSONObject(object, options: nil, error: &e)
            if e {
                error.memory = e
                return false
            }

        } else {
            error.memory = NSError(domain: CycleErrorDomain,
                                   code: CycleErrorCode.ObjectKindNotMatch.toRaw(),
                                   userInfo: nil)
            return false
        }

        return true
    }

    override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        var e: NSError?
        response.object = NSJSONSerialization.JSONObjectWithData(response.data,
                                                                 options: .AllowFragments,
                                                                 error: &e)
        if e {
            error.memory = e
            return false
        }
        return true
    }
}

class FORMProcessor : Processor {
    override func processRequest(request: Request, error: NSErrorPointer) -> Bool {
        if let object = request.object as? Dictionary<String, String[]> {
            request.object = FormencodeDictionary(object)
            request.core.setValue("application/x-www-form-urlencoded",
                                  forHTTPHeaderField: "Content-Type")

        } else {
            error.memory = NSError(domain: CycleErrorDomain,
                code: CycleErrorCode.ObjectKindNotMatch.toRaw(),
                userInfo: nil)
            return false
        }

        return true
    }

    override func processResponse(response: Response, error: NSErrorPointer) -> Bool {
        assert(false)
        return false
    }
}
