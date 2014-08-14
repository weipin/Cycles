//
//  KVOCenter.swift
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

import UIKit

public typealias KeyValueObserverProxyCallback = (keyPath: String, observed: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) -> Void

public class KeyValueObserverProxy: NSObject {
    weak var observed: AnyObject!
    weak var observer: AnyObject!
    var keyPath: String!
    var queue: NSOperationQueue!
    var callback: KeyValueObserverProxyCallback!

    override public func observeValueForKeyPath(keyPath: String, ofObject: AnyObject,
    change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if let queue = self.queue {
            queue.addOperationWithBlock {
                self.callback(keyPath: keyPath, observed:ofObject, change:change, context:context)
            }
        } else {
            self.callback(keyPath: keyPath, observed:ofObject, change:change, context:context)
        }
    }
}

public class KeyValueObservingCenter {
    public class var sharedInstance: KeyValueObservingCenter {
        struct Singleton {
            static let instance = KeyValueObservingCenter()
        }
        return Singleton.instance
    }

    var dict = Dictionary<NSValue, [KeyValueObserverProxy]>()

    func addObserverProxy(proxy: KeyValueObserverProxy) {
        var v = NSValue(nonretainedObject: proxy.observer)
        var proxies = self.dict[v]
        if proxies == nil {
            proxies = [KeyValueObserverProxy]()
        }
        proxies!.append(proxy)
        self.dict[v] = proxies // TODO: Have to assign back, the value obtained from dictionary is always a copy?
    }

    public func addObserver(observer: NSObject!, keyPath: String!,
    options: NSKeyValueObservingOptions = .New, context: UnsafeMutablePointer<()> = nil,
    observed: AnyObject!, queue: NSOperationQueue = NSOperationQueue.mainQueue(),
    callback: KeyValueObserverProxyCallback) -> KeyValueObserverProxy {
        var proxy = KeyValueObserverProxy()
        proxy.observed = observed
        proxy.observer = observer
        proxy.keyPath = keyPath
        proxy.queue = queue
        proxy.callback = callback
        self.addObserverProxy(proxy)

        observed.addObserver(proxy, forKeyPath: keyPath, options: options, context: context)
        return proxy
    }

    public func removeObserver(observer: NSObject, keyPath: String? = nil, observed: AnyObject? = nil) {
        if let proxy = observer as? KeyValueObserverProxy {
            // find the proxy and remove it
            for (key, var proxies) in self.dict {
                var found: Int?
                for (index, i) in enumerate(proxies) {
                    if proxy != i {
                        continue
                    }
                    found = index
                    break
                }

                if found != nil {
                    proxy.observed.removeObserver(proxy, forKeyPath: proxy.keyPath)
                    proxies.removeAtIndex(found!)
                }
            }
            return
        }

        var v = NSValue(nonretainedObject: observer)
        if let proxies = self.dict[v] {
            var newAry = filter(proxies) { (proxy: KeyValueObserverProxy) -> Bool in
                if keyPath != nil && keyPath != proxy.keyPath {
                    return true
                }
                if observed != nil && observed !== proxy.observed {
                    return true
                }

                proxy.observed.removeObserver(proxy, forKeyPath: proxy.keyPath)
                return false
            }
            self.dict[v] = newAry
        }
    } // func
}

