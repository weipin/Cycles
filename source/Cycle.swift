//
//  Cycle.swift
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

public enum CycleType {
    case Data, Upload, Download
}

public typealias CycleCompletionHandler = (cycle: Cycle, error: NSError?) -> Void
public typealias CycleDidSendBodyDataHandler = (cycle: Cycle, bytesSent: Int64,
                                                totalBytesSent: Int64,
                                                totalBytesExpectedToSend: Int64) -> Void
public typealias CycleDidWriteBodyDataHandler = (cycle: Cycle, bytesWritten: Int64,
                                                 totalBytesWritten: Int64,
                                                 totalBytesExpectedToWrite: Int64) -> Void
public typealias CycleDownloadFileHander = (cycle: Cycle, location: NSURL?) -> Void

/*!
 * This class represents a HTTP cycle, including request and response.
 */
@objc public class Cycle {
/*!
 * The CycleType determines what kind of NSURLSessionTask to create. The
 * default type is Data.
 */
    public var taskType: CycleType

/*!
 * The Session which acts as the manager of the Cycle.
 */
    public weak var session: Session!

/*!
 * The URL for the request.
 */
    public var requestURL: NSURL {
        return self.request.core.URL!
    }

/*!
 * The HTTP method for the request.
 */
    public var requestMethod: String {
    get {
        return self.request.core.HTTPMethod
    }
    set {
        self.request.core.HTTPMethod = newValue
    }
    }

    var _requestProcessors: [Processor]?
/*!
 * An array of Processor subclass objects. Before the request is being sent,
 * the Request goes through all the processor objects to initialize parameters.
 * If nil, the session's requestProcessors will be used.
 */
    public var requestProcessors: [Processor] {
    get{
        if self._requestProcessors != nil {
            return self._requestProcessors!
        }
        return self.session.requestProcessors
    }
    set{
        self._requestProcessors = newValue
    }
    }

    var _responseProcessors: [Processor]?
/*!
 * An array of Processor subclass objects. When a transfer finishes successfully,
 * the Response goes through all the processor objects to build the response object.
 * If nil, the session's responseProcessors will be used.
 */
    public var responseProcessors: [Processor] {
    get{
        if self._responseProcessors != nil {
            return self._responseProcessors!
        }
        return self.session.responseProcessors
    }
    set{
        self._responseProcessors = newValue
    }
    }

/*!
 * Called when the content of the given URL is retrieved or an error occurs.
 */
    public var completionHandler: CycleCompletionHandler!

/*!
 * Affect the Cycle's retry logic. If solicited is true, the number of retries is
 * unlimited until the transfer finishes successfully.
 */
    public var solicited = false

/*!
 * The identifier for a cycle, supposed to be unique in one `Service`.
 */
    public var identifier = ""

    var _authentications: [Authentication]?
/*!
 * An array of Authentication subclass objects. If the HTTP task requires
 * credentials, the objects will be enumerated one by one and
 * canHandleAuthenticationChallenge will be invoked for each object against
 * the same arguments. The objects return true will be used to handle the
 * authentication. If nil, the session's authenticationHandlers will be
 * used.
 */
    public var authentications: [Authentication] {
    get{
        if self._authentications != nil {
            return self._authentications!
        }
        return self.session.authentications
    }
    set{
        self._authentications = newValue
    }
    }

/*!
 * Called with upload progress information.
 */
    public var didSendBodyDataHandler: CycleDidSendBodyDataHandler?

/*!
 * Called with download progress information.
 */
    public var didWriteDataHandler: CycleDidWriteBodyDataHandler?

/*!
 * Called with the URL to a temporary file where the downloaded content is stored.
 */
    public var downloadFileHandler: CycleDownloadFileHander?

/*!
 * The NSData to upload for a upload task.
 */
    public var dataToUpload: NSData?

/*!
 * The URL of the file to upload for a upload task.
 */
    public var fileToUpload: NSURL?

/*!
 * The NSURLSessionTask that Cycle creates for you.
 */
    public var core: NSURLSessionTask?

/*!
 * The Request represents the HTTP request. Cycle creates it for you, you should
 * not create it by yourself
 */
    public var request: Request

/*!
 * The Response represents the HTTP response. Cycle creates it for you, you should
 * not create it by yourself
 */
    public var response: Response!

/*!
 * How many retries have been attempted.
 */
    public var retriedCount = 0

/*!
 * Indicate if the operation was cancelled explicitly.
 */
    public var explicitlyCanceling = false

/*!
 * @abstract 
 * Initialize a Cycle object
 *
 * @param requestURL
 * The URL for the request.
 *
 * @param taskType 
 * The CycleType indicates the NSURLSessionTask to create.
 *
 * @param session 
 * The Session to use for the HTTP operations.
 *
 * @param requestMethod 
 * The HTTP method for the request.
 *
 * @param requestObject 
 * The object represents the request data.
 *
 * @param requestProcessors 
 * An array of Processor subclass objects.
 *
 * @param responseProcessors 
 * An array of Processor subclass objects.
 */
    public init(requestURL: NSURL,
    taskType: CycleType = CycleType.Data,
    session: Session? = nil,
    requestMethod: String = "GET",
    requestObject: AnyObject? = nil,
    requestProcessors: [Processor]? = nil,
    responseProcessors: [Processor]? = nil) {
        self.taskType = taskType
        var r = NSURLRequest(URL: requestURL)
        self.request = Request(core: r)
        self.request.object = requestObject
        self.requestMethod = requestMethod

        if session != nil {
            self.session = session!
        } else {
            self.session = Session.defaultSession()
        }

        if requestProcessors != nil {
            self.requestProcessors = requestProcessors!
        }
        if responseProcessors != nil {
            self.responseProcessors = responseProcessors!
        }

        self.session.addCycle(self)
    }

    deinit {
        self.reset()
    }

    public func taskForType(type: CycleType) -> NSURLSessionTask {
        var task: NSURLSessionTask?
        switch (self.taskType) {
        case .Data:
            task = self.session.core.dataTaskWithRequest(self.request.core)
        case .Upload:
            assert((self.dataToUpload != nil && self.fileToUpload == nil)
                || (self.dataToUpload == nil && self.fileToUpload != nil));
            if self.dataToUpload != nil {
                task = self.session.core.uploadTaskWithRequest(self.request.core, fromData:self.dataToUpload);
            }
            if self.fileToUpload != nil {
                task = self.session.core.uploadTaskWithRequest(self.request.core, fromFile:self.fileToUpload!);
            }
        case .Download:
            assert(self.downloadFileHandler != nil);
            task = self.session.core.downloadTaskWithRequest(self.request.core);
        default:
            assert(false)
        }
        return task!
    }

    public func prepare(completionHandler: ((result: Bool) -> Void)) {
        if self.core != nil {
            return
        }

        self.response = Response()
        self.session.workerQueue.addOperationWithBlock {
            var result = true
            if (self.taskType == .Data) {
                for i in self.requestProcessors {
                    if (!i.processRequest(self.request, error: nil)) {
                        result = false
                        break
                    }
                }
            }

            NSOperationQueue.mainQueue().addOperationWithBlock {
                completionHandler(result: result)
            }
        }
    }

/*!
 * @abstract 
 * Start the HTTP request operation.
 *
 * @param completionHandler 
 * Called when the content of the given URL is retrieved
 * or an error occurred.
 */
    public func start(completionHandler: CycleCompletionHandler? = nil) {
        if completionHandler != nil {
            self.completionHandler = completionHandler
        }
        assert(self.completionHandler != nil)

        if self.core != nil {
            self.core!.resume()
            return
        }

        var index = self.session.indexOfCycle(self)
        if index == nil {
            // Cycle already cancelled.
            // For example, cancelled when the cycle is waiting for a retry.
            return
        }

        self.prepare {(result: Bool) in
            if self.core != nil {
                // task could have been assigned and started in another thread
                return
            }

            if !result {
                var e = NSError(domain: CycleErrorDomain,
                    code: CycleErrorCode.PreparationFailure.rawValue,
                    userInfo: nil)
                self.session.cycleDidFinish(self, error: e)
                return
            }

            self.session.applyPreservedStateToRequest(self.request)

            self.core = self.taskForType(self.taskType)
            self.request.timestamp = NSDate()
            self.core!.resume()
            self.session.cycleDidStart(self)
        }
        return
    }

    public func reset() {
        self.core = nil
        self.request.timestamp = nil
        self.response = nil
        self.explicitlyCanceling = false
    }

/*!
 * @abstract 
 * Stop the current HTTP request operation and start again.
 */
    public func restart() {
        self.cancel(true)
        self.reset()
        self.start()
    }

/*!
 * @abstract 
 * Cancel the HTTP request operation.
 *
 * @param explicitly 
 * Indicate if the operation is cancelled explicitly. The value will be stored 
 * in property explicitlyCanceling. Your app can use this value for cancellation 
 * interface.
 */
    public func cancel(explicitly: Bool) {
        self.session.cancelCycles([self], explicitly:explicitly)
    }
}

