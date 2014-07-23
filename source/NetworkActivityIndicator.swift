//
//  NetworkActivityIndicator.swift
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

/*!
 * This class manages the display of network activity, a spinning indicator in 
 * the status bar shows network activity.
 * 
 * In most cases, you create one single NetworkActivityIndicator for one app. 
 * To make this NetworkActivityIndicator manage the activity display, you call
 * the method `increate` each time a request is issued, and call the method 
 * `decrease` each time a response is received or ended with an error.
 */
public class NetworkActivityIndicator {
    var count = 0

    class func sharedInstance() -> NetworkActivityIndicator {
        struct Singleton {
            static var instance: NetworkActivityIndicator? = nil
            static var onceToken: dispatch_once_t = 0
        }

        dispatch_once(&Singleton.onceToken) {
            Singleton.instance = self()
        }
        
        return Singleton.instance!
    }

    public required init() {

    }

/*!
 * @discussion 
 * Increase the internal count. Display the network activity if the count is 
 * larger than 0.
 */
    public func increase() {
        ++self.count;
        if 1 == self.count {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
        }
    }

/*!
 * @discussion 
 * Decrease the internal count. Hide the network activity when the count reaches 0.
 */
    public func decrease() {
        --self.count;
        if 0 == self.count {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
        }
    }
}
