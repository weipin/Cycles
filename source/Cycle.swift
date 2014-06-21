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
    case Unknown, Data, Upload, Download
}

typealias CycleCompletionHandler = (cycle: Cycle, error: NSError?) -> Void
typealias CycleDidSendBodyDataHandler = (cycle: Cycle, bytesSent: Int64,
                                         totalBytesSent: Int64,
                                         totalBytesExpectedToSend: Int64) -> Void
typealias CycleDidWriteBodyDataHandler = (cycle: Cycle, bytesWritten: Int64,
                                          totalBytesWritten: Int64,
                                          totalBytesExpectedToWrite: Int64) -> Void
typealias CycleDownloadFileHander = (cycle: Cycle, location: NSURL) -> Void

class Cycle {
    var taskType: CycleType
    weak var session: Session!
    var requestURL: NSURL {
        return self.request.core.URL
    }
    var requestMethod: String {
        return self.request.core.HTTPMethod
    }
    var requestObject: AnyObject?
    var _requestProcessors: Processor[]?
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
    var completionHandler: CycleCompletionHandler

    var solicited = false
    var _authentications: Authentication[]?
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
    var didSendBodyDataHandler: CycleDidSendBodyDataHandler?
    var didWriteDataHandler: CycleDidWriteBodyDataHandler?
    var downloadFileHandler: CycleDownloadFileHander?
    var dataToUpload: NSData?
    var fileToUpload: NSURL?

    var core: NSURLSessionTask?
    var request: Request
    var response: Response!
    var retriedCount = 0
    var explicitlyCanceling = false

    init(requestURL: NSURL, completionHandler: CycleCompletionHandler,
    taskType: CycleType = CycleType.Data,
    session: Session,
    requestMethod: String = "GET",
    requestObject: AnyObject? = nil,
    requestProcessors: Processor[]? = nil,
    responseProcessors: Processor[]? = nil) {
        self.taskType = taskType
        self.completionHandler = completionHandler

        var r = NSURLRequest(URL: requestURL)
        self.request = Request(core: r)
        self.request.core.HTTPMethod = self.requestMethod
        self.request.object = self.requestObject

        self.session = session
        self.requestObject = requestObject
        self.requestProcessors = requestProcessors!
        self.responseProcessors = responseProcessors!

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

    func start() -> Bool {
        var index = self.session.indexOfCycle(self)
        if !index {
            // Cancelled. 
            // For example, cancelled when the cycle is waiting for a retry
            return true
        }

        var result = true
        self.prepare {
            if !$0 {
                result = false
                return
            }

            self.core = self.taskForType(self.taskType)
            self.request.timestamp = NSDate()
            self.core!.resume()
        }
        return result
    }

    func reset() {
        assert(self.core != nil)
        assert(self.core!.state == NSURLSessionTaskState.Completed)

        self.core = nil
        self.request.timestamp = nil
        self.response = nil
        self.explicitlyCanceling = false
    }

    func restart() {
        self.reset()
        self.start()
    }

    func cancel(explicitly: Bool) {
        self.session.cancelCycles([self], explicitly:explicitly)
    }
}

