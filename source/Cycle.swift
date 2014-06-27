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

enum CycleType {
    case Data, Upload, Download
}

typealias CycleCompletionHandler = (cycle: Cycle, error: NSError?) -> Void
typealias CycleDidSendBodyDataHandler = (cycle: Cycle, bytesSent: Int64,
                                         totalBytesSent: Int64,
                                         totalBytesExpectedToSend: Int64) -> Void
typealias CycleDidWriteBodyDataHandler = (cycle: Cycle, bytesWritten: Int64,
                                          totalBytesWritten: Int64,
                                          totalBytesExpectedToWrite: Int64) -> Void
typealias CycleDownloadFileHander = (cycle: Cycle, location: NSURL?) -> Void

/*!
 This class represents a HTTP cycle, including request and response.
 */
class Cycle {
/*!
 The CycleType determines what kind of NSURLSessionTask to create. The
 default type is Data.
 */
    var taskType: CycleType

/*!
 The Session which acts as the manager of the Cycle.
 */
    weak var session: Session!

/*!
 The URL for the request.
 */
    var requestURL: NSURL {
        return self.request.core.URL
    }

/*!
 The HTTP method for the request.
 */
    var requestMethod: String {
    get {
        return self.request.core.HTTPMethod
    }
    set {
        self.request.core.HTTPMethod = newValue
    }
    }

    var _requestProcessors: Processor[]?
/*!
 An array of Processor subclass objects. Before the request is being sent,
 the Request goes through all the processor objects to initialize parameters.
 If nil, the session's requestProcessors will be used.
 */
    var requestProcessors: Processor[] {
    get{
        if (self._requestProcessors) {
            return self._requestProcessors!
        }
        return self.session.requestProcessors
    }
    set{
        self._requestProcessors = newValue
    }
    }

    var _responseProcessors: Processor[]?
/*!
 An array of Processor subclass objects. When a transfer finishes successfully, 
 the Response goes through all the processor objects to build the response object.
 If nil, the session's responseProcessors will be used.
 */
    var responseProcessors: Processor[] {
    get{
        if (self._responseProcessors) {
            return self._responseProcessors!
        }
        return self.session.responseProcessors
    }
    set{
        self._responseProcessors = newValue
    }
    }

/*!
 Called when the content of the given URL is retrieved or an error occurs.
 */
    var completionHandler: CycleCompletionHandler!

/*!
 Affect the Cycle's retry logic. If solicited is true, the number of retries is
 unlimited until the transfer finishes successfully.
 */
    var solicited = false

    var _authentications: Authentication[]?
/*!
 An array of Authentication subclass objects. If the HTTP task requires
 credentials, the objects will be enumerated one by one and 
 canHandleAuthenticationChallenge will be invoked for each object against
 the same arguments. The objects return true will be used to handle the 
 authentication. If nil, the session's authenticationHandlers will be
 used.
 */
    var authentications: Authentication[] {
    get{
        if (self._authentications) {
            return self._authentications!
        }
        return self.session.authentications
    }
    set{
        self._authentications = newValue
    }
    }

/*!
 Called with upload progress information.
 */
    var didSendBodyDataHandler: CycleDidSendBodyDataHandler?

/*!
 Called with download progress information.
 */
    var didWriteDataHandler: CycleDidWriteBodyDataHandler?

/*!
 Called with the URL to a temporary file where the downloaded content is stored.
 */
    var downloadFileHandler: CycleDownloadFileHander?

/*!
 The NSData to upload for a upload task.
 */
    var dataToUpload: NSData?

/*!
 The URL of the file to upload for a upload task.
 */
    var fileToUpload: NSURL?

/*!
 The NSURLSessionTask that Cycle creates for you.
 */
    var core: NSURLSessionTask?

/*
 The Request represents the HTTP request. Cycle creates it for you, you should
 not create it by yourself
 */
    var request: Request

/*
 The Response represents the HTTP response. Cycle creates it for you, you should 
 not create it by yourself
 */
    var response: Response!

/*
 How many retries have been attempted.
 */
    var retriedCount = 0

/*
 Indicate if the operation was cancelled explicitly.
 */
    var explicitlyCanceling = false

/*!
 @abstract Initialize a Cycle object
 @param requestURL The URL for the request.
 @param taskType The CycleType indicates the NSURLSessionTask to create.
 @param session The Session to use for the HTTP operations.
 @param requestMethod The HTTP method for the request.
 @param requestObject The object represents the request data.
 @param requestProcessors An array of Processor subclass objects.
 @param responseProcessors An array of Processor subclass objects.
 */
    init(requestURL: NSURL,
    taskType: CycleType = CycleType.Data,
    session: Session? = nil,
    requestMethod: String = "GET",
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil,
    responseProcessors: Processor[]? = nil) {
        self.taskType = taskType
        var r = NSURLRequest(URL: requestURL)
        self.request = Request(core: r)
        self.request.object = requestObject
        self.requestMethod = requestMethod

        if session {
            self.session = session!
        } else {
            self.session = Session.defaultSession()
        }

        if requestProcessors {
            self.requestProcessors = requestProcessors!
        }
        if responseProcessors {
            self.responseProcessors = responseProcessors!
        }

        self.session.addCycle(self)
    }

    deinit {
        self.reset()
    }

    func taskForType(type: CycleType) -> NSURLSessionTask {
        var task: NSURLSessionTask?
        switch (self.taskType) {
        case .Data:
            task = self.session.core.dataTaskWithRequest(self.request.core)
        case .Upload:
            assert((self.dataToUpload && !self.fileToUpload)
                || (!self.dataToUpload && self.fileToUpload));
            if (self.dataToUpload) {
                task = self.session.core.uploadTaskWithRequest(self.request.core, fromData:self.dataToUpload);
            }
            if (self.fileToUpload) {
                task = self.session.core.uploadTaskWithRequest(self.request.core, fromFile:self.fileToUpload);
            }
        case .Download:
            assert(self.downloadFileHandler);
            task = self.session.core.downloadTaskWithRequest(self.request.core);
        default:
            assert(false)
        }
        return task!
    }

    func prepare(completionHandler: ((result: Bool) -> Void)) {
        if self.core {
            return
        }

        self.response = Response()

        var originalThread = NSThread.currentThread()
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
            RunOnThread(originalThread, false, {
                completionHandler(result: result)
            });
        }
    }

/*!
 @abstract Start the HTTP request operation.
 @param completionHandler Called when the content of the given URL is retrieved
 or an error occurred.
 */
    func start(completionHandler: CycleCompletionHandler? = nil) {
        if completionHandler {
            self.completionHandler = completionHandler
        }
        assert(self.completionHandler)

        var index = self.session.indexOfCycle(self)
        if !index {
            // Cycle already cancelled.
            // For example, cancelled when the cycle is waiting for a retry.
            return
        }

        self.prepare {(result: Bool) in
            if !result {
                var e = NSError(domain: CycleErrorDomain,
                    code: CycleErrorCode.PreparationFailure.toRaw(),
                    userInfo: nil)
                self.session.onCycleDidFinish(self, error: e)
                return
            }

            self.core = self.taskForType(self.taskType)
            self.request.timestamp = NSDate()
            self.core!.resume()
        }
        return
    }

    func reset() {
        self.core = nil
        self.request.timestamp = nil
        self.response = nil
        self.explicitlyCanceling = false
    }

/*!
 @abstract Stop the current HTTP request operation and start again.
 */
    func restart() {
        self.cancel(true)
        self.reset()
        self.start()
    }

/*!
 @abstract Cancel the HTTP request operation.
 @param explicitly Indicate if the operation is cancelled explicitly. The value 
 will be stored in property explicitlyCanceling. Your app can use this value for
 cancellation interface.
 */
    func cancel(explicitly: Bool) {
        self.session.cancelCycles([self], explicitly:explicitly)
    }
}

