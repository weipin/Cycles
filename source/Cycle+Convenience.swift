//
//  Cycle+Convenience.swift
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

extension Cycle {
    class func createAndStartCycle(URLString: String, method: String,
    parameters: Dictionary<String, String[]>? = nil,
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    completionHandler: CycleCompletionHandler) {
        var str = URLString
        if parameters {
            str = MergeParametersToURL(URLString, parameters!)
        }
        var URL = NSURL(string: str)
        var cycle = Cycle(requestURL: URL,
                          taskType: CycleType.Data,
                          requestMethod: method,
                          requestObject: requestObject,
                          requestProcessors: requestProcessors,
                          responseProcessors: responseProcessors)
        if (authentications) {
            cycle.authentications = authentications!
        }
        cycle.start(completionHandler: completionHandler)
    }

    class func get(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    completionHandler: CycleCompletionHandler) {
        return self.createAndStartCycle(URLString, method: "GET", parameters: parameters,
                                        requestProcessors: requestProcessors,
                                        responseProcessors: responseProcessors,
                                        authentications: authentications,
                                        completionHandler: completionHandler);
    }

}

