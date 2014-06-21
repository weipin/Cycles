//
//  Session.swift
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
import UIKit

class Session: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate,
NSURLSessionDataDelegate {
    var core: NSURLSession!
    var delegateQueue: NSOperationQueue
    var workerQueue: NSOperationQueue
    var requestProcessors = Processor[]()
    var responseProcessors = Processor[]()
    var retryDelay: dispatch_time_t = 3
    var authentications = Authentication[]()

    var cycles = Cycle[]()

    let RetryPolicyMaximumRetryCount = 3 // TODO, use Type Variable

    class func defaultSession() -> Session {
        struct Singleton {
            static var instance: Session? = nil
            static var onceToken: dispatch_once_t = 0
        }

        dispatch_once(&Singleton.onceToken) {
            Singleton.instance = self()
        }

        return Singleton.instance!
    }

    @required init(configuration: NSURLSessionConfiguration? = nil,
    delegateQueue: NSOperationQueue? = nil,
    workerQueue: NSOperationQueue? = nil) {
        var c = configuration
        if !c {
            c = NSURLSessionConfiguration.defaultSessionConfiguration()
        }
        if let delegate = delegateQueue {
            self.delegateQueue = delegate
        } else {
            self.delegateQueue = NSOperationQueue.mainQueue()
        }
        if let delegate = workerQueue {
            self.workerQueue = delegate
        } else {
            self.workerQueue = NSOperationQueue()
        }

        super.init()
        self.core = NSURLSession(configuration: c, delegate: self,
                                 delegateQueue: delegateQueue)
    }

    func indexOfCycle(cycle: Cycle) -> Int? {
        var index: Int?
        for (i, object) in enumerate(self.cycles) {
            if object !== cycle {
                continue
            }
            index = i
            break
        }
        return index
    }

    func addCycle(cycle: Cycle) {
        if let index = self.indexOfCycle(cycle) {
            assert(false)
            return
        }

        self.cycles.append(cycle)
    }

    func removeCycle(cycle: Cycle) {
        var index = indexOfCycle(cycle)
        if index {
            self.cycles.removeAtIndex(index!)
        }
    }

    func cycleForTask(task: NSURLSessionTask) -> Cycle? {
        var cycle: Cycle?
        for i in self.cycles {
            if i.core !== task {
                continue
            }
            cycle = i
            break
        }
        return cycle
    }

    func shouldRetry(solicited: Bool, retriedCount: Int, request: Request,
    response:Response, error: NSError) -> Bool {
        if solicited {
            return true
        }

        if retriedCount > self.RetryPolicyMaximumRetryCount {
            return false
        }

        if error.domain == NSURLErrorDomain && error.code == NSURLErrorTimedOut {
            return true
        }

        if response.statusCode == 408 || response.statusCode == 503 {
            return true
        }

        return false
    }

    // NSURLSessionTaskDelegate
    func URLSession(session: NSURLSession!, task: NSURLSessionTask!,
    didCompleteWithError error: NSError!) {
        var cycle: Cycle! = self.cycleForTask(task)
        assert(cycle != nil)

        cycle.response.core = task.response as? NSHTTPURLResponse
        assert(cycle.response.core != nil)
        cycle.response.timestamp = NSDate()

        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            self.delegateQueue.addOperationWithBlock {
                if !cycle.explicitlyCanceling {
                    cycle.completionHandler(cycle: cycle, error: error)
                }
                self.removeCycle(cycle)
            }
            return
        }

        var retry = self.shouldRetry(cycle.solicited, retriedCount: cycle.retriedCount,
            request: cycle.request, response: cycle.response, error: error)
        if retry {
            ++cycle.retriedCount
            dispatch_after(self.retryDelay, self.delegateQueue.underlyingQueue) {
                cycle.restart()
            }
            return
        }

        if cycle.response.statusCode >= 400 {
            var error = NSError(domain: CycleErrorDomain,
                                code: CycleErrorCode.StatusCodeSeemsToHaveErred.toRaw(),
                                userInfo: nil)
            cycle.completionHandler(cycle: cycle, error: error)
            return
        }

        self.workerQueue .addOperationWithBlock {
            var error: NSError?
            for i in cycle.responseProcessors {
                if !i.processResponse(cycle.response, error: &error) {
                    break
                }
            }
            self.delegateQueue.addOperationWithBlock {
                cycle.completionHandler(cycle: cycle, error: error)
                self.removeCycle(cycle)
            }
        }

    }

    func URLSession(session: NSURLSession!, task: NSURLSessionTask!,
    didSendBodyData bytesSent: Int64, totalBytesSent: Int64,
    totalBytesExpectedToSend: Int64) {
        var cycle = self.cycleForTask(task)
        assert(cycle)

        cycle!.didSendBodyDataHandler?(cycle: cycle!, bytesSent: bytesSent,
                                       totalBytesSent: totalBytesSent,
                                       totalBytesExpectedToSend: totalBytesExpectedToSend)
    }


    func URLSession(session: NSURLSession!, task: NSURLSessionTask!,
    didReceiveChallenge challenge: NSURLAuthenticationChallenge!,
    completionHandler: ((NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void)!) {
        var cycle = self.cycleForTask(task)!
        assert(cycle != nil)

        var handlers = cycle.authentications
        var count = 0
        for handler in handlers {
            if handler.canHandleAuthenticationChallenge(challenge, cycle: cycle) {
                ++count
                var action = handler.actionForAuthenticationChallenge(challenge, cycle: cycle)
                handler.performAction(action, challenge: challenge,
                                      completionHandler: completionHandler,
                                      cycle: cycle)
            }
        }
        if count == 0 {
            completionHandler(NSURLSessionAuthChallengeDisposition.PerformDefaultHandling, nil)
        }
    }

    // NSURLSessionDataDelegate

    func URLSession(session: NSURLSession!, dataTask: NSURLSessionDataTask!,
    didReceiveData data: NSData!) {
        var cycle = self.cycleForTask(dataTask)!
        assert(cycle != nil)

        cycle.response.appendData(data)
    }

    // NSURLSessionDownloadDelegate
    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!,
    didFinishDownloadingToURL location: NSURL!) {
        var cycle = self.cycleForTask(downloadTask)!
        assert(cycle != nil)

        cycle.downloadFileHandler?(cycle: cycle, location: location)
    }

    func URLSession(session: NSURLSession!, downloadTask: NSURLSessionDownloadTask!,
    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
    totalBytesExpectedToWrite: Int64) {
        var cycle = self.cycleForTask(downloadTask)!
        assert(cycle != nil)

        cycle.didWriteDataHandler?(cycle: cycle, bytesWritten: bytesWritten,
                                   totalBytesWritten: totalBytesWritten,
                                   totalBytesExpectedToWrite: totalBytesExpectedToWrite);
    }

    // ---
    func cancelCycles(cycles: Cycle[], explicitly: Bool) {
        for cycle in cycles {
            cycle.explicitlyCanceling = explicitly
            cycle.core!.cancel()
        }
    }

    func invalidateAndCancel(explicitly: Bool) {
        for cycle in cycles {
            cycle.explicitlyCanceling = explicitly
        }
        self.core.invalidateAndCancel()
    }

    func finishTaskAndInvalidate(explicitly: Bool) {
        for cycle in cycles {
            cycle.explicitlyCanceling = explicitly
        }
        self.core.finishTasksAndInvalidate()
    }
}