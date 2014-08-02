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
    case RequestProcessors = "RequestProcessors"
    case ResponseProcessors = "ResponseProcessors"
}

enum CycleForResourceOption {
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
    var cyclesWithIdentifier = Dictionary<String, Cycle>()

    class func filenameOfDefaultProfile() -> String {
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

        } else {
            self.updateProfileFromLocalFile()
        }
    }

    func updateProfileFromLocalFile(URL: NSURL? = nil) -> Bool {
        var objectClass: AnyClass! = self.classForCoder

        if !URL {
            var filename = objectClass.filenameOfDefaultProfile()
            if let profile = objectClass.profileForFilename(filename) {
                self.profile = profile
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
        }
        return false
    }

    func verifyProfile(profile: Dictionary<String, AnyObject>? = nil) -> Bool {
        if !profile {
            self.profile = profile
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
        }

        return true
    }

    func resourceProfileForName(name: String) -> Dictionary<String, String>? {
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

    func cycleForIdentifer(identifier: String) -> Cycle? {
        return self.cyclesWithIdentifier[identifier]
    }

    func cycleForResourceWithIdentifer(name: String, identifier: String? = nil,
    option: CycleForResourceOption = .Reuse, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool = false) -> Cycle {
        var cycle: Cycle!
        if identifier {
            cycle = self.cyclesWithIdentifier[identifier!]
            if cycle {
                if option == .Reuse {
                    return cycle!
                } else if option == .Replace {
                    cycle!.cancel(true)
                    self.cyclesWithIdentifier.removeValueForKey(identifier!)
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
            var value = resourceProfile[ServiceKey.RequestProcessors.toRaw()]
            var requestProcessorObjects = [Processor]()
            if let requestProcessorClasses = value?.componentsSeparatedByString(",") {
                for i in requestProcessorClasses {
                    if let theClass: AnyClass = NSClassFromString(i) {
                        if let type = theClass as? Processor.Type {
                            var processor = type()
                            requestProcessorObjects.append(processor)
                        }
                    }
                } // for requestProcessorClasses
            } // if requestProcessorClasses

            value = resourceProfile[ServiceKey.ResponseProcessors.toRaw()]
            var responseProcessorObjects = [Processor]()
            if let responseProcessorClasses = value?.componentsSeparatedByString(",") {
                for i in responseProcessorClasses {
                    if let theClass: AnyClass = NSClassFromString(i) {
                        if let type = theClass as? Processor.Type {
                            var processor = type()
                            responseProcessorObjects.append(processor)
                        }
                    }
                } // for responseProcessorClasses
            } // if responseProcessorClasses

            var URLString = self.baseURLString
            var URITemplate = resourceProfile[ServiceKey.URITemplate.toRaw()]
            if countElements(URITemplate!) > 0 {
                var part1 = self.baseURLString
                var part2 = ExpandURITemplate(URITemplate!, URIValues)
                if countElements(part1) > 0 && part1[part1.endIndex] == "/" {
                    part1 = part1[part1.startIndex ..< advance(part1.endIndex, -1)]
                }
                if countElements(part2) > 0 && part2[part2.startIndex] == "/" {
                    part2 = part2[advance(part2.startIndex, 1) ..< part1.endIndex]
                }
                URLString = part1 + "/" + part2
            }

            var URL = NSURL.URLWithString(URLString)
            assert(URL)

            var method = resourceProfile[ServiceKey.Method.toRaw()]
            if !method {
                method = "GET"
            }

            cycle = Cycle(requestURL: URL, taskType: .Data, session: self.session,
                requestMethod: method!, requestObject: requestObject)
            cycle.solicited = solicited
            if countElements(requestProcessorObjects) > 0 {
                cycle.requestProcessors = cycle.requestProcessors + requestProcessorObjects
            }
            if countElements(responseProcessorObjects) > 0 {
                cycle.responseProcessors = cycle.responseProcessors + responseProcessorObjects
            }

        } else {
            assert(false)
        }

        return cycle!
    }

    func cycleForResource(name: String, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool = false) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        return cycle
    }

    func requestResourceWithIdentifer(name: String, identifier: String? = nil,
    URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool = false, completionHandler: CycleCompletionHandler) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name, identifier: identifier,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

    func requestResource(name: String, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool = false, completionHandler: CycleCompletionHandler) -> Cycle {
        var cycle = self.requestResourceWithIdentifer(name, identifier: nil,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited,
            completionHandler: completionHandler)
        return cycle
    }

} // class Service
