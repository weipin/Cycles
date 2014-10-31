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
    case Reuse /* If there is a Cycle with the specified identifier, the Service will reuse it. */
    case Replace /* If there is a Cycle with the specified identifier, the Service will cancel it, create a new Cycle and replace the existing one. */
}

/*!
 * @discussion 
 * This class is an abstract class you use to represent a "service".
 * Because it is abstract, you do not use this class directly but instead
 * subclass.
 */
public class Service: NSObject {
    var _baseURLString: String?

/*!
 * The string represents the first part of all URLs the Serivce will produce.
 */
    var baseURLString: String {
    get {
        if (_baseURLString != nil) {
            return _baseURLString!
        }
        var value: AnyObject? = self.profile[ServiceKey.BaseURL.rawValue]
        if let str = value as? String {
            return str
        }
        return ""
    }
    set {
        self._baseURLString = newValue
    }
    }

/*!
 * A Dictionary describes the resources of a service.
 */
    public var profile: Dictionary<String, AnyObject>!
    var session: Session!

/*!
 * MUST be overridden
 */
    public class func className() -> String {
        //TODO: Find a way to obtain class name
        assert(false)
        return "Service"
    }

    class func filenameOfDefaultProfile() -> String {
        var className = self.className()
        var filename = className + ".plist"
        return filename
    }

/*!
 * Override this method to customize the Session
 */
    public func defaultSession() -> Session {
        return Session()
    }

/*!
 * Override this method to customize the specific Cycles.
 */
    public func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {

    }

/*!
 * Find and read a service profile in the bundle with specified filename.
 */
    class func profileForFilename(filename: String) -> Dictionary<String, AnyObject>? {
        var theClass: AnyClass! = self.classForCoder()
        var bundle = NSBundle(forClass: theClass)
        var URL = bundle.URLForResource(filename, withExtension: nil)
        if URL == nil {
            println("file not found for: \(filename)");
            return nil
        }
        var error: NSError?
        var data = NSData(contentsOfURL:URL!, options: NSDataReadingOptions(0), error: &error)
        if data == nil {
            println("\(error?.description)");
            return nil
        }
        return self.profileForData(data!)
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
        if !part1.isEmpty && part1.hasSuffix("/") {
            p1 = part1[part1.startIndex ..< advance(part1.endIndex, -1)]
        }
        if !part2.isEmpty && part2.hasPrefix("/") {
            p2 = part2[advance(part2.startIndex, 1) ..< part2.endIndex]
        }
        var result = p1 + "/" + p2
        return result
    }

/*!
 * @abstract 
 * Initialize a Session object
 *
 * @param profile
 * A dictionary for profile. If nil, the bundled default file will be read to create
 * the dictionary.
 */
    public init(profile: Dictionary<String, AnyObject>? = nil) {
        super.init()

        self.session = self.defaultSession()
        if profile != nil {
            self.profile = profile

        } else {
            self.updateProfileFromLocalFile()
        }
    }

    public func updateProfileFromLocalFile(URL: NSURL? = nil) -> Bool {
        var objectClass: AnyClass! = self.classForCoder

        if URL == nil {
            var filename = self.dynamicType.filenameOfDefaultProfile()
            if let profile = self.dynamicType.profileForFilename(filename) {
                self.profile = profile
                return true
            }
            return false
        }

        var error: NSError?
        var data = NSData(contentsOfURL: URL!, options: NSDataReadingOptions(0), error: &error)
        if data == nil {
            println("\(error?.description)");
            return false
        }
        if let profile = objectClass.profileForData(data!) {
            self.profile = profile
            return true
        }
        return false
    }

/*!
 * @abstract 
 * Check if specified profile is valid
 *
 * @param profile
 * A dictionary as profile.
 *
 * @result
 * true if valid, or false if an error occurs.
 */
    public func verifyProfile(profile: Dictionary<String, AnyObject>) -> Bool {
        var names = NSMutableSet()
        if let value: AnyObject = profile[ServiceKey.Resources.rawValue] {
            if let resources = value as? [Dictionary<String, String>] {
                for (index, resource) in enumerate(resources) {
                    if let name = resource[ServiceKey.Name.rawValue] {
                        if names.containsObject(name) {
                            println("Error: Malformed Resources (duplicate name) in Service profile (resource index: \(index))!");
                            return false
                        }
                        names.addObject(name)

                    } else {
                        println("Error: Malformed Resources (name not found) in Service profile (resource index: \(index))!");
                        return false
                    }

                    if resource[ServiceKey.URITemplate.rawValue] == nil {
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
        assert(self.profile != nil)

        if let value: AnyObject = profile![ServiceKey.Resources.rawValue] {
            if let resources = value as? [Dictionary<String, String>] {
                for resource in resources {
                    if let n = resource[ServiceKey.Name.rawValue] {
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

/*!
 * @abstract 
 * Create a Cycle object based on the specified resource profile and parameters
 *
 * @param name
 * The name of the resouce, MUST present in the profile. The name is case sensitive.
 *
 * @param identifer
 * If present, the identifer will be used to locate an existing cycle.
 *
 * @param option
 * Decide the Cycle creation logic if a Cycle with the specified identifer already exists.
 *
 * @param URIValues
 * The object to provide values for the URI Template expanding.
 *
 * @param requestObject 
 * The property object of the Request for the Cycle.
 *
 * @param solicited
 * The same property of Cycle.
 *
 * @result
 * A new or existing Cycle.
 */
    public func cycleForResourceWithIdentifer(name: String, identifier: String? = nil,
    option: CycleForResourceOption = .Replace, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil,
    solicited: Bool = false) -> Cycle {
        var cycle: Cycle!
        if identifier != nil {
            cycle = self.cycleForIdentifer(identifier!)
            if cycle != nil {
                if option == .Reuse {

                } else if option == .Replace {
                    cycle.cancel(true)
                    cycle = nil
                } else {
                    assert(false)
                }
            }
        } // if identifier

        if cycle != nil {
            return cycle
        }

        if let resourceProfile = self.resourceProfileForName(name) {
            var URITemplate = resourceProfile[ServiceKey.URITemplate.rawValue]
            var part2 = ExpandURITemplate(URITemplate!, values: URIValues)
            var URLString = Service.URLStringByJoiningComponents(self.baseURLString, part2: part2)

            var URL = NSURL(string: URLString)
            assert(URL != nil)

            var method = resourceProfile[ServiceKey.Method.rawValue]
            if method == nil {
                method = "GET"
            }

            cycle = Cycle(requestURL: URL!, taskType: .Data, session: self.session,
                requestMethod: method!, requestObject: requestObject)
            cycle.solicited = solicited
            if identifier != nil {
                cycle.identifier = identifier!
                self.session.addCycleToCycleWithIdentifiers(cycle)
            }
            self.cycleDidCreateWithResourceName(cycle, name: name)

        } else {
            assert(false)
        }

        return cycle!
    }

/*!
 * @abstract 
 * Create a Cycle object based on the specified resource profile and parameters
 *
 * @param name
 * The name of the resouce, MUST present in the profile. The name is case sensitive.
 *
 * @param URIValues
 * The object to provide values for the URI Template expanding.
 *
 * @param requestObject 
 * The property object of the Request for the Cycle.
 *
 * @param solicited
 * The same property of Cycle.
 *
 * @result
 * A new Cycle.
 */
    public func cycleForResource(name: String, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil, solicited: Bool = false) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        return cycle
    }

/*!
 * @abstract 
 * Create a Cycle object based on the specified resource profile and parameters,
 * and start the Cycle.
 *
 * @param name
 * The name of the resouce, MUST present in the profile. The name is case sensitive.
 *
 * @param identifer
 * If present, the identifer will be used to locate an existing cycle.
 *
 * @param URIValues
 * The object to provide values for the URI Template expanding.
 *
 * @param requestObject 
 * The property object of the Request for the Cycle.
 *
 * @param solicited
 * The same property of Cycle.
 *
 * @param completionHandler
 * Called when the content of the given resource is retrieved
 * or an error occurred.
 *
 * @result
 * A new Cycle.
 */
    public func requestResourceWithIdentifer(name: String, identifier: String,
    URIValues: AnyObject? = nil, requestObject: AnyObject? = nil,
    solicited: Bool = false, completionHandler: CycleCompletionHandler) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name, identifier: identifier,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

/*!
 * @abstract 
 * Create a Cycle object based on the specified resource profile and parameters,
 * and start the Cycle.
 *
 * @param name
 * The name of the resouce, MUST present in the profile. The name is case sensitive.
 *
 * @param URIValues
 * The object to provide values for the URI Template expanding.
 *
 * @param requestObject 
 * The property object of the Request for the Cycle.
 *
 * @param solicited
 * The same property of Cycle.
 *
 * @param completionHandler
 * Called when the content of the given resource is retrieved
 * or an error occurred.
 *
 * @result
 * A new Cycle.
 */
    public func requestResource(name: String, URIValues: AnyObject? = nil,
    requestObject: AnyObject? = nil, solicited: Bool = false,
    completionHandler: CycleCompletionHandler) -> Cycle {
        var cycle = self.cycleForResourceWithIdentifer(name, identifier: nil,
            URIValues: URIValues, requestObject: requestObject, solicited: solicited)
        cycle.start(completionHandler: completionHandler)
        return cycle
    }

} // class Service
