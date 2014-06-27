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
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
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
        cycle.solicited = solicited
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

/*!
 @abstract Send a GET request and retrieve the content of the given URL.
 @param URLString The URL for the request.
 @param parameters The parameters of the query.
 @param requestProcessors An array of Processor subclass objects.
 @param responseProcessors An array of Processor subclass objects.
 @param authentications An array of Authentication objects.
 @param solicited Affect the Cycle's retry logic. If solicited is YES, the 
 number of retries is unlimited until the transfer finishes successfully.
 @param completionHandler Called when the content of the given URL is retrieved 
 or an error occurs.
 */
    class func get(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        return self.createAndStartCycle(URLString, method: "GET", parameters: parameters,
                                        requestProcessors: requestProcessors,
                                        responseProcessors: responseProcessors,
                                        authentications: authentications,
                                        solicited: solicited,
                                        completionHandler: completionHandler);
    }

/*!
 @discussion Send a HEAD request and retrieve the content of the given URL. 
 */
    class func head(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        return self.createAndStartCycle(URLString, method: "HEAD", parameters: parameters,
            requestProcessors: requestProcessors,
            responseProcessors: responseProcessors,
            authentications: authentications,
            solicited: solicited,
            completionHandler: completionHandler);
    }

/*!
 @discussion Send a POST request and retrieve the content of the given URL.
 */
    class func post(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        return self.createAndStartCycle(URLString, method: "POST", parameters: parameters,
            requestObject: requestObject,
            requestProcessors: requestProcessors,
            responseProcessors: responseProcessors,
            authentications: authentications,
            solicited: solicited,
            completionHandler: completionHandler);
    }

/*!
 @discussion Send a PUT request and retrieve the content of the given URL.
 */
    class func put(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        return self.createAndStartCycle(URLString, method: "PUT", parameters: parameters,
            requestObject: requestObject,
            requestProcessors: requestProcessors,
            responseProcessors: responseProcessors,
            authentications: authentications,
            solicited: solicited,
            completionHandler: completionHandler);
    }

/*!
 @discussion Send a PATCH request and retrieve the content of the given URL.
 */
    class func patch(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        return self.createAndStartCycle(URLString, method: "PATCH", parameters: parameters,
            requestObject: requestObject,
            requestProcessors: requestProcessors,
            responseProcessors: responseProcessors,
            authentications: authentications,
            solicited: solicited,
            completionHandler: completionHandler);
    }

/*!
 @discussion Send a DELETE request and retrieve the content of the given URL.
 */
    class func delete(URLString: String, parameters: Dictionary<String, String[]>? = nil,
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil, responseProcessors: Processor[]? = nil,
    authentications: Authentication[]? = nil,
    solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        return self.createAndStartCycle(URLString, method: "DELETE", parameters: parameters,
            requestObject: requestObject,
            requestProcessors: requestProcessors,
            responseProcessors: responseProcessors,
            authentications: authentications,
            solicited: solicited,
            completionHandler: completionHandler);
    }

/*!
 @abstract Upload data to the given URL.
 @param URLString The URL for the request.
 @param dataToUpload The data to upload.
 @param parameters The parameters of the query.
 @param authentications An array of Authentication objects.
 @param didSendDataHandler Called with upload progress information.
 @param completionHandler Called when the content of the given URL is retrieved 
 or an error occurs.
 */
    class func upload(URLString: String, dataToUpload: NSData,
    parameters: Dictionary<String, String[]>? = nil,
    authentications: Authentication[]? = nil,
    didSendBodyDataHandler: CycleDidSendBodyDataHandler? = nil,
    completionHandler: CycleCompletionHandler) -> Cycle {
        var str = URLString
        if parameters {
            str = MergeParametersToURL(URLString, parameters!)
        }
        var URL = NSURL(string: str)
        var cycle = Cycle(requestURL: URL,
                          taskType: CycleType.Upload,
                          requestMethod: "POST")
        if (authentications) {
            cycle.authentications = authentications!
        }
        cycle.dataToUpload = dataToUpload
        cycle.didSendBodyDataHandler = didSendBodyDataHandler
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

/*!
 @abstract Upload a local file to the given URL.
 @param fileToUpload The URL of the file to upload for a upload task.
 */
    class func upload(URLString: String, fileToUpload: NSURL,
    parameters: Dictionary<String, String[]>? = nil,
    authentications: Authentication[]? = nil,
    didSendBodyDataHandler: CycleDidSendBodyDataHandler? = nil,
    completionHandler: CycleCompletionHandler) -> Cycle {
        var str = URLString
        if parameters {
            str = MergeParametersToURL(URLString, parameters!)
        }
        var URL = NSURL(string: str)
        var cycle = Cycle(requestURL: URL,
                          taskType: CycleType.Upload,
                          requestMethod: "POST")
        if (authentications) {
            cycle.authentications = authentications!
        }
        cycle.fileToUpload = fileToUpload
        cycle.didSendBodyDataHandler = didSendBodyDataHandler
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

/*!
 @abstract Download data from the given URL.
 @param URLString The URL for the request.
 @param parameters The parameters of the query.
 @param authentications An array of Authentication objects.
 @param didWriteDataHandler Called with download progress information.
 @param downloadFileHandler Called with the URL to a temporary file where the 
 downloaded content is stored.
 @param completionHandler Called when the content of the given URL is retrieved 
 or an error occurs.
 */
    class func download(URLString: String,
    parameters: Dictionary<String, String[]>? = nil,
    authentications: Authentication[]? = nil,
    didWriteDataHandler: CycleDidWriteBodyDataHandler? = nil,
    downloadFileHandler: CycleDownloadFileHander,
    completionHandler: CycleCompletionHandler) -> Cycle {
        var str = URLString
        if parameters {
            str = MergeParametersToURL(URLString, parameters!)
        }
        var URL = NSURL(string: str)
        var cycle = Cycle(requestURL: URL,
                          taskType: CycleType.Download,
                          requestMethod: "GET")
        if (authentications) {
            cycle.authentications = authentications!
        }
        cycle.didWriteDataHandler = didWriteDataHandler
        cycle.downloadFileHandler = downloadFileHandler
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

}

