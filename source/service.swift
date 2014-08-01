//
//  service.swift
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

enum ServiceKey: String {
    case BaseURL = "BaseURL"
    case Resources = "Resources"
    case Name = "Name"
    case URITemplate = "URITemplate"
    case RequestProcessors = "RequestProcessors"
    case ResponseProcessors = "ResponseProcessors"
}

enum CycleForResourceOption {
    case Create
    case Reuse
}

public class Service: NSObject {
    var _baseURLString: String?

    var baseURLString: String {
    get {
        if (_baseURLString) {
            return _baseURLString!
        }
        var value: AnyObject? = self.profile[ServiceKey.BaseURL.toRaw()]
        if let str = value as? String {
            return str
        }
        return ""
    }
    set {
        self._baseURLString = newValue
    }
    }

    var profile: Dictionary<String, AnyObject>!
    var session: Session!
    var cyclesWithIdentifier = Dictionary<String, Cycle>()

    class func filenameOfProfile() -> String {
        var className = NSStringFromClass(self)
        var filename = className + ".plist"
        return filename
    }

    func defaultSession() -> Session {
        return Session()
    }

    class func profileForFilename(filename: String) -> Dictionary<String, AnyObject>? {
        var className = NSStringFromClass(self)
        var bundle = NSBundle(forClass: NSClassFromString(className))
        if bundle == nil {
            return nil
        }
        var URL = bundle.URLForResource(filename, withExtension: nil)
        if URL == nil {
            println("file not found at: \(URL.absoluteString)");
            return nil
        }
        var error: NSError?
        var data = NSData.dataWithContentsOfURL(URL, options: NSDataReadingOptions(0), error: &error)
        if data == nil {
            println("\(error?.description)");
            return nil
        }
        return self.profileForData(data)
    }

    class func profileForData(data: NSData) -> Dictionary<String, AnyObject>? {
        var error: NSError?
        var profile = NSPropertyListSerialization.propertyListWithData(data,
        options: 0, format: nil, error: &error) as Dictionary<String, AnyObject>?

        return profile
    }

    init(profile: Dictionary<String, AnyObject>?) {
        super.init()

        self.session = self.defaultSession()
        if profile {
            self.profile = profile
        }
    }

    func updateProfileFromLocalFile(URL: NSURL?) -> Bool {

    }

    func verifyProfile(profile: Dictionary<String, AnyObject>?) -> Bool {

    }

    func cycleForResource(name: String, identifier: String? = nil,
    option: CycleForResourceOption = .Create, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool? = false) -> Cycle {

    }

    func requestResource(name: String, identifier: String? = nil,
    option: CycleForResourceOption = .Create, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool? = false, completionHandler: CycleCompletionHandler) -> Cycle {
            
    }

} // class Service
