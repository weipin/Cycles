//
//  URITemplate.swift
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

/*!
* @abstract
* Expand a URITemplate
*
* @dicussion
* This is a convenient version of the `process` method in class `URITemplate`
*
* @param template
* The URITemplate to expand
*
* @param values
* The object to provide values when the function expands the URI Template.
* It can be a Swift Dictionary, a NSDictionary, a NSDictionary subclass or any
* object has method `objectForKey`.
*
* @result
* The expanded URITemplate
*/
public func ExpandURITemplate(template: String, values: AnyObject? = nil) -> String {
    var provider: AnyObject? = values
    if provider == nil {
        provider = Dictionary<String, AnyObject>()
    }
    let (URLString, errors) = URITemplate().process(template, values: provider!);
    return URLString
}

public enum URITemplateError {
    case MalformedPctEncodedInLiteral
    case NonLiteralsCharacterFoundInLiteral
    case ExpressionEndedWithoutClosing
    case NonExpressionFound
    case InvalidOperator
    case MalformedVarSpec
}

enum State {
    case ScanningLiteral
    case ScanningExpression
}

enum ExpressionState {
    case ScanningVarName
    case ScanningModifier
}

enum BehaviorAllow {
    case U // any character not in the unreserved set will be encoded
    case UR // any character not in the union of (unreserved / reserved / pct-encoding) will be encoded
}

struct Behavior {
    var first: String
    var sep: String
    var named: Bool
    var ifemp: String
    var allow: BehaviorAllow
}

/*!
* @discussion
* This class is an implementation of URI Template (RFC6570). You probably
* wouldn't need to use this class but the convenient function ExpandURITemplate.
*/
public class URITemplate {
    // TODO: Use type variable
    struct ClassVariable {
        static let BehaviorTable = [
            "NUL": Behavior(first: "",  sep: ",", named: false, ifemp: "",  allow: .U),
            "+"  : Behavior(first: "",  sep: ",", named: false, ifemp: "",  allow: .UR),
            "."  : Behavior(first: ".", sep: ".", named: false, ifemp: "",  allow: .U),
            "/"  : Behavior(first: "/", sep: "/", named: false, ifemp: "",  allow: .U),
            ";"  : Behavior(first: ";", sep: ";", named: true,  ifemp: "",  allow: .U),
            "?"  : Behavior(first: "?", sep: "&", named: true,  ifemp: "=", allow: .U),
            "&"  : Behavior(first: "&", sep: "&", named: true,  ifemp: "=", allow: .U),
            "#"  : Behavior(first: "#", sep: ",", named: false, ifemp: "",  allow: .UR),
        ]

        static let LEGAL = "!*'();:@&=+$,/?%#[]" // Legal URL characters (based on RFC 3986)
        static let HEXDIG = "0123456789abcdefABCDEF"
        static let DIGIT = "0123456789"
        static let RESERVED = ":/?#[]@!$&'()*+,;="
        static let UNRESERVED = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~" // 66
        static let VARCHAR = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_" // exclude pct-encoded
    }

    let BehaviorTable = ClassVariable.BehaviorTable
    let LEGAL = ClassVariable.LEGAL
    let HEXDIG = ClassVariable.HEXDIG
    let DIGIT = ClassVariable.DIGIT
    let RESERVED = ClassVariable.RESERVED
    let UNRESERVED = ClassVariable.UNRESERVED
    let VARCHAR = ClassVariable.VARCHAR

    // Pct-encoded ignored
    func encodeLiteralString(string: String) -> String {
        var charactersToLeaveUnescaped = self.RESERVED + self.UNRESERVED
        var s = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            string as NSString, charactersToLeaveUnescaped as NSString,
            nil,
            CFStringBuiltInEncodings.UTF8.rawValue)
        var result = s as NSString
        return result
    }

    func encodeLiteralCharacter(character: Character) -> String {
        return encodeLiteralString(String(character))
    }

    func encodeStringWithBehaviorAllowSet(string: String, allow: BehaviorAllow) -> String {
        var result = ""

        if allow == .U {
            var s = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                string as NSString, UNRESERVED as NSString,
                LEGAL as NSString,
                CFStringBuiltInEncodings.UTF8.rawValue)
            result = s as NSString

        } else if allow == .UR {
            result = encodeLiteralString(string)
        } else {
            assert(false)
        }

        return result
    }


    func stringOfAnyObject(object: AnyObject?) -> String? {
        if object == nil {
            return nil
        }

        if let str = object as? String {
            return str
        }

        if let str = object?.stringValue {
            return str
        }

        return nil
    }

    func findOperatorInExpression(expression: String) -> (op: Character?, error: URITemplateError?) {
        var count = countElements(expression)

        if count == 0 {
            return (nil, URITemplateError.InvalidOperator)
        }

        var op: Character? = nil
        var error: URITemplateError? = nil
        var startCharacher = expression[expression.startIndex]
        if startCharacher == "%" {
            if count < 3 {
                return (nil, URITemplateError.InvalidOperator)
            }

            var c1 = expression[advance(expression.startIndex, 1)]
            var c2 = expression[advance(expression.startIndex, 2)]
            if find(HEXDIG, c1) == nil {
                return (nil, URITemplateError.InvalidOperator)
            }
            if find(HEXDIG, c2) == nil {
                return (nil, URITemplateError.InvalidOperator)
            }
            var str = "%" + String(c1) + String(c2)
            str = str.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? ""
            op = str[str.startIndex]
        } else {
            op = startCharacher
        }

        if op != nil {
            if (BehaviorTable[String(op!)] == nil) {
                if (find(VARCHAR, op!) == nil) {
                    return (nil, URITemplateError.InvalidOperator)
                } else {
                    return (nil, nil)
                }
            }
        }

        return (op, error)
    }

    func expandVarSpec(varName: String, modifier: Character?, prefixLength :Int,
        behavior: Behavior, values: AnyObject) -> String {
            var result = ""

            if varName == "" {
                return result
            }

            var value: AnyObject?
            if let d = values as? Dictionary<String, AnyObject> {
                value = d[varName]
            } else if let d = values as? NSDictionary {
                value = d.objectForKey(varName)
            } else {
                value = values.objectForKey?(varName)
            }

            if let str = stringOfAnyObject(value) {
                if behavior.named {
                    result += encodeLiteralString(varName)
                    if str == "" {
                        result += behavior.ifemp
                        return result
                    } else {
                        result += "="
                    }
                }
                if modifier == ":" && prefixLength < countElements(str) {
                    var prefix = str[str.startIndex ..< advance(str.startIndex, prefixLength)]
                    result += encodeStringWithBehaviorAllowSet(prefix, allow: behavior.allow)

                } else {
                    result += encodeStringWithBehaviorAllowSet(str, allow: behavior.allow)
                }

            } else {
                if modifier == "*" {
                    if behavior.named {
                        if let ary = value as? [AnyObject] {
                            var count = 0
                            for v in ary {
                                var str = stringOfAnyObject(v)
                                if str == nil {
                                    continue
                                }
                                if count > 0 {
                                    result += behavior.sep
                                }
                                result += encodeLiteralString(varName)
                                if str! == "" {
                                    result += behavior.ifemp
                                } else {
                                    result += "="
                                    result += encodeStringWithBehaviorAllowSet(str!, allow: behavior.allow)

                                }
                                ++count
                            }


                        } else if let dict = value as? Dictionary<String, AnyObject> {
                            var keys = Array(dict.keys)
                            keys = sorted(keys) {(s1: String, s2: String) -> Bool in
                                return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedDescending
                            }

                            var count = 0
                            for k in keys {
                                var str: String? = nil
                                if let v: AnyObject = dict[k] {
                                    str = stringOfAnyObject(v)
                                }
                                if str == nil {
                                    continue
                                }
                                if count > 0 {
                                    result += behavior.sep
                                }
                                result += encodeLiteralString(k)
                                if str == "" {
                                    result += behavior.ifemp
                                } else {
                                    result += "="
                                    result += encodeStringWithBehaviorAllowSet(str!, allow: behavior.allow)
                                }
                                ++count
                            }

                        } else {
                            NSLog("Value for varName %@ is not a list or a pair", varName);
                        }

                    } else {
                        if let ary = value as? [AnyObject] {
                            var count = 0
                            for v in ary {
                                var str = stringOfAnyObject(v)
                                if str == nil {
                                    continue
                                }
                                if count > 0 {
                                    result += behavior.sep
                                }
                                result += encodeStringWithBehaviorAllowSet(str!, allow: behavior.allow)
                                ++count
                            }

                        } else if let dict = value as? Dictionary<String, AnyObject> {
                            var keys = Array(dict.keys)
                            keys = sorted(keys) {(s1: String, s2: String) -> Bool in
                                return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedDescending
                            }

                            var count = 0
                            for k in keys {
                                var str: String? = nil
                                if let v: AnyObject = dict[k] {
                                    str = stringOfAnyObject(v)
                                }
                                if str == nil {
                                    continue
                                }
                                if count > 0 {
                                    result += behavior.sep
                                }
                                result += encodeLiteralString(k)
                                result += "="
                                result += encodeStringWithBehaviorAllowSet(str!, allow: behavior.allow)
                                ++count
                            }

                        } else {
                            NSLog("Value for varName %@ is not a list or a pair", varName);
                        }
                    } // if behavior.named

                } else {
                    // no explode modifier is given
                    var flag = true
                    if behavior.named {
                        result += encodeLiteralString(varName)
                        if value == nil {
                            result += behavior.ifemp
                            flag = false
                        } else {
                            result += "="
                        }

                        if flag {

                        }
                    } // if behavior.named

                    if let ary = value as? [AnyObject] {
                        var count = 0
                        for v in ary {
                            var str = stringOfAnyObject(v)
                            if str == nil {
                                continue
                            }
                            if count > 0 {
                                result += ","
                            }
                            result += encodeStringWithBehaviorAllowSet(str!, allow: behavior.allow)
                            ++count
                        }

                    } else if let dict = value as? Dictionary<String, AnyObject> {
                        var keys = Array(dict.keys)
                        keys = sorted(keys) {(s1: String, s2: String) -> Bool in
                            return s1.localizedCaseInsensitiveCompare(s2) == NSComparisonResult.OrderedDescending
                        }

                        var count = 0
                        for k in keys {
                            var str: String? = nil
                            if let v: AnyObject = dict[k] {
                                str = stringOfAnyObject(v)
                            }
                            if str == nil {
                                continue
                            }
                            if count > 0 {
                                result += ","
                            }
                            result += encodeStringWithBehaviorAllowSet(k, allow: behavior.allow)
                            result += ","
                            result += encodeStringWithBehaviorAllowSet(str!, allow: behavior.allow)
                            ++count
                        }
                        
                    } else {
                        
                    }
                    
                } // if modifier == "*"
                
            }
            return result
    }
    

/*!
 * @abstract
 * Expand a URITemplate
 *
 * @param template
 * The URITemplate to expand
 *
 * @param values
 * The object to provide values when the method expands the URITemplate. 
 * It can be a Swift Dictionary, a NSDictionary, a NSDictionary subclass or any 
 * object has method `objectForKey`.
 * 
 * @result (result, errors)
 * result
 * The expanded URITemplate
 * errors
 * An array of tuple (URITemplateError, Int) which represents the errors this method 
 * recorded in expanding the URITemplate. The first element indicates the type of 
 * error, the second element indicates the position (index) of the error in the URITemplate.
 */
    public func process(template: String, values: AnyObject) -> (String, Array<(URITemplateError, Int)>) {
        var state: State = .ScanningLiteral
        var result = ""
        var pctEncoded = ""
        var expression = ""
        var expressionCount = 0
        var errors = Array<(URITemplateError, Int)>()

        for (index, c) in enumerate(template) {
            switch state {
            case .ScanningLiteral:
                if c == "{" {
                    state = .ScanningExpression
                    ++expressionCount

                } else if (!pctEncoded.isEmpty) {
                    switch countElements(pctEncoded) {
                    case 1:
                        if find(HEXDIG, c) != nil {
                            pctEncoded += String(c)
                        } else {
                            errors.append((URITemplateError.MalformedPctEncodedInLiteral, index))
                            result += encodeLiteralString(pctEncoded)
                            result += encodeLiteralCharacter(c)
                            state = .ScanningLiteral
                            pctEncoded = ""
                        }

                    case 2:
                        if find(HEXDIG, c) != nil {
                            pctEncoded += String(c)
                            result += pctEncoded
                            state = .ScanningLiteral
                            pctEncoded = ""

                        } else {
                            errors.append((URITemplateError.MalformedPctEncodedInLiteral, index))
                            result += encodeLiteralString(pctEncoded)
                            result += encodeLiteralCharacter(c)
                            state = .ScanningLiteral
                            pctEncoded = ""
                        }

                    default:
                        assert(false)
                    }

                } else if c == "%" {
                    pctEncoded += String(c)
                    state = .ScanningLiteral

                } else if find(UNRESERVED, c) != nil || find(RESERVED, c) != nil {
                    result += String(c)

                } else {
                    errors.append((URITemplateError.NonLiteralsCharacterFoundInLiteral, index))
                    result += String(c)
                }

            case .ScanningExpression:
                if c == "}" {
                    state = .ScanningLiteral
                    // Process expression
                    let (op, error) = findOperatorInExpression(expression)
                    if error != nil {
                        errors.append((URITemplateError.MalformedPctEncodedInLiteral, index))
                        result = result + "{" + expression + "}"

                    } else {
                        var operatorString = (op != nil) ? String(op!) : "NUL"
                        var behavior = BehaviorTable[operatorString]!;
                        // Skip the operator
                        var skipCount = 0
                        if op != nil {
                            if expression.hasPrefix("%") {
                                skipCount = 3
                            } else {
                                skipCount = 1
                            }
                        }
                        // Process varspec-list
                        var varCount = 0
                        var eError: URITemplateError? = nil
                        var estate = ExpressionState.ScanningVarName
                        var varName = ""
                        var modifier: Character?
                        var prefixLength :Int = 0
                        var str = expression[advance(expression.startIndex, skipCount)..<expression.endIndex]
                        str = str.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? ""
                        var jIndex = 0
                        for (jIndex, j) in enumerate(str) {
                            if j == "," {
                                // Process VarSpec
                                if varCount == 0 {
                                    result += behavior.first
                                } else {
                                    result += behavior.sep
                                }
                                var expanded = expandVarSpec(varName, modifier:modifier, prefixLength:prefixLength, behavior:behavior, values:values)
                                result += expanded
                                ++varCount

                                // Reset for next VarSpec
                                eError = nil
                                estate = .ScanningVarName
                                varName = ""
                                modifier = nil
                                prefixLength = 0
                                
                                continue
                            }

                            if (estate == .ScanningVarName) {
                                if (j == "*" || j == ":") {
                                    if varName.isEmpty {
                                        eError = .MalformedVarSpec
                                        break;
                                    }
                                    modifier = j
                                    estate = .ScanningModifier
                                    continue
                                }
                                if find(VARCHAR, j) != nil || j == "." {
                                    varName += String(j)
                                } else {
                                    eError = .MalformedVarSpec
                                    break;
                                }

                            } else if (estate == .ScanningModifier) {
                                if modifier == "*" {
                                    eError = .MalformedVarSpec
                                    break;
                                } else if modifier == ":" {
                                    if find(DIGIT, j) != nil {
                                        var intValue = String(j).toInt()
                                        prefixLength = prefixLength * 10 + intValue!
                                        if prefixLength >= 1000 {
                                            eError = .MalformedVarSpec
                                            break;
                                        }

                                    } else {
                                        eError = .MalformedVarSpec
                                        break;
                                    }
                                } else {
                                    assert(false);
                                }

                            } else {
                                assert(false)
                            }
                        } // for expression

                        if (eError != nil) {
                            let e = eError!
                            let ti = index + jIndex
                            errors.append((e, ti))
                            let remainingExpression = str[advance(str.startIndex, jIndex)..<str.endIndex]
                            if op != nil {
                                result = result + "{" + String(op!) + remainingExpression + "}"
                            } else {
                                result = result + "{" + remainingExpression + "}"
                            }

                        } else {
                            // Process VarSpec
                            if varCount == 0 {
                                result += behavior.first
                            } else {
                                result += behavior.sep
                            }
                            var expanded = expandVarSpec(varName, modifier: modifier, prefixLength: prefixLength, behavior: behavior, values: values)
                            result += expanded
                        }
                    } // varspec-list

                } else {
                    expression += String(c);
                }

            default:
                assert(false)
            } // switch
        }// for

        // Handle ending
        let endingIndex: Int = countElements(template)
        if state == .ScanningLiteral {
            if !pctEncoded.isEmpty {
                errors.append((URITemplateError.MalformedPctEncodedInLiteral, endingIndex))
                result += encodeLiteralString(pctEncoded)
            }

        } else if (state == .ScanningExpression) {
            errors.append((URITemplateError.ExpressionEndedWithoutClosing, endingIndex))
            result = result + "{" + expression

        } else {
            assert(false);
        }
        if expressionCount == 0 {
            errors.append((URITemplateError.NonExpressionFound, endingIndex))
        }

        return (result, errors)
    } // process

} // URITemplate

