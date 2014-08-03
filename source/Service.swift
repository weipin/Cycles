//
//  Service.swift
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
    case Method = "Method"
}

public enum CycleForResourceOption {
    case Reuse
    case Replace
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

    public class func className() -> String {
        assert(false)
        return "Service"
    }

    class func filenameOfDefaultProfile() -> String {
        var className = self.className()
        var filename = className + ".plist"
        return filename
    }

    public func defaultSession() -> Session {
        return Session()
    }

    public func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
    }

    class func profileForFilename(filename: String) -> Dictionary<String, AnyObject>? {
        var theClass: AnyClass! = self.classForCoder()
        var bundle = NSBundle(forClass: theClass)
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

    public class func URLStringByJoiningComponents(part1: String, part2: String) -> String {
        if part1.isEmpty {
            return part2
        }

        if part2.isEmpty {
            return part1
        }

        var p1 = part1
        var p2 = part2
        if !part1.isEmpty && part1[advance(part1.endIndex, -1)] == "/" {
            p1 = part1[part1.startIndex ..< advance(part1.endIndex, -1)]
        }
        if !part2.isEmpty && part2[part2.startIndex] == "/" {
            p2 = part2[advance(part2.startIndex, 1) ..< part2.endIndex]
        }
        var result = p1 + "/" + p2
        return result
    }

    public init(profile: Dictionary<String, AnyObject>? = nil) {
        super.init()

        self.session = self.defaultSession()
        if profile {
            self.profile = profile

        } else {
            self.updateProfileFromLocalFile()
        }
    }

    public func updateProfileFromLocalFile(URL: NSURL? = nil) -> Bool {
        var objectClass: AnyClass! = self.classForCoder

        if !URL {
            var filename = self.dynamicType.filenameOfDefaultProfile()
            if let profile = self.dynamicType.profileForFilename(filename) {
                self.profile = profile
                return true
            }
            return false
        }

        var error: NSError?
        var data = NSData.dataWithContentsOfURL(URL, options: NSDataReadingOptions(0), error: &error)
        if data == nil {
            println("\(error?.description)");
            return false
        }
        if let profile = objectClass.profileForData(data) {
            self.profile = profile
            return true
        }
        return false
    }

    public func verifyProfile(serviceProfile: Dictionary<String, AnyObject>? = nil) -> Bool {
        var profile = serviceProfile
        if !profile {
            profile = self.profile
        }
        assert(profile)

        var names = NSMutableSet()
        if let value: AnyObject = profile![ServiceKey.Resources.toRaw()] {
            if let resources = value as? [Dictionary<String, String>] {
                for (index, resource) in enumerate(resources) {
                    if let name = resource[ServiceKey.Name.toRaw()] {
                        if names.containsObject(name) {
                            println("Error: Malformed Resources (duplicate name) in Service profile (resource index: \(index))!");
                            return false
                        }
                        names.addObject(name)

                    } else {
                        println("Error: Malformed Resources (name not found) in Service profile (resource index: \(index))!");
                        return false
                    }

                    if !resource[ServiceKey.URITemplate.toRaw()] {
                        println("Error: Malformed Resources (URL Template not found) in Service profile (resource index: \(index))!");
                        return false
                    }

                }
            } else {
                println("Error: Malformed Resources in Service profile (type does not match)!");
                return false
            }

        } else {
            println("Warning: no resources found in Service profile!");
            return false
        }

        return true
    }

    public func resourceProfileForName(name: String) -> Dictionary<String, String>? {
        assert(self.profile)

        if let value: AnyObject = profile![ServiceKey.Resources.toRaw()] {
            if let resources = value as? [Dictionary<String, String>] {
                for resource in resources {
                    if let n = resource[ServiceKey.Name.toRaw()] {
                        if n == name {
                            return resource
                        }
                    }
                }
            }
        }

        return nil
    }

    public func cycleForIdentifer(identifier: String) -> Cycle? {
        return self.session.cycleForIdentifer(identifier)
    }

    public func cycleForResourceWithIdentifer(name: String, identifier: String? = nil,
    option: CycleForResourceOption = .Replace, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool = false) -> Cycle {
        var cycle: Cycle!
        if identifier {
            cycle = self.cycleForIdentifer(identifier!)
            if cycle {
                if option == .Reuse {

                } else if option == .Replace {
                    cycle.cancel(true)
                    cycle = nil
                } else {
                    assert(false)
                }
            }
        } // if identifier

        if cycle {
            return cycle
        }

        if let resourceProfile = self.resourceProfileForName(name) {
            var URITemplate = resourceProfile[ServiceKey.URITemplate.toRaw()]
            var part2 = ExpandURITemplate(URITemplate!, values: URIValues)
            var URLString = Service.URLStringByJoiningComponents(self.baseURLString, part2: part2)

            var URL = NSURL.URLWithString(URLString)
            assert(URL)

            var method = resourceProfile[ServiceKey.Method.toRaw()]
            if !method {
                method = "GET"
            }

            cycle = Cycle(requestURL: URL, taskType: .Data, session: self.session,
                requestMethod: method!, requestObject: requestObject)
            cycle.solicited = solicited
            if identifier {
                cycle.identifier = identifier!
                self.session.addCycleToCycleWithIdentifiers(cycle)
            }
            self.cycleDidCreateWithResourceName(cycle, name: name)

        } else {
            assert(false)
        }

        return cycle!
    }

    public func cycleForResource(name: String, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil, solicited: Bool = false) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        return cycle
    }

    public func requestResourceWithIdentifer(name: String, identifier: String,
    URIValues: AnyObject? = nil, requestObject: AnyObject? = nil,
    solicited: Bool = false, completionHandler: CycleCompletionHandler) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name, identifier: identifier,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

    public func requestResource(name: String, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil, solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name, identifier: nil,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

} // class Service
