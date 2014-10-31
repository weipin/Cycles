//
//  Authentication.swift
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

public enum AuthenticationAction {
    case ProvidingCredentials /* Use the specified credential */
    case ProvidingCredentialsWithInteraction /* Display an interface for user to input the credential */
    case PerformDefaultHandling /* Default handling for the challenge - as if this handler were not implemented; the credential parameter is ignored */
    case RejectProtectionSpace /* This challenge is rejected and the next authentication protection space should be tried;the credential parameter is ignored */
    case CancelingConnection /* The entire request will be canceled; the credential parameter is ignored */
}

public typealias AuthenticationCompletionHandler = (disposition: NSURLSessionAuthChallengeDisposition,
    credential: NSURLCredential!) -> Void
public typealias AuthenticationInteractionCompletionHandler = (action: AuthenticationAction) -> Void

/*!
 * @discussion
 * This class is an abstract class you use to encapsulate the code and data 
 * associated with HTTP authentication. Because it is abstract, you do not use 
 * this class directly but instead subclass or use one of the existing 
 * subclasses (BasicAuthentication) to perform the actual handling.
 */
public class Authentication {
    var challenge: NSURLAuthenticationChallenge! = nil
    var completionHandler: AuthenticationCompletionHandler! = nil
    weak var cycle: Cycle! = nil
    var interacting = false

    public init() {

    }

    public func perform(action: AuthenticationAction) {
        switch (action) {
        case .ProvidingCredentials:
            self.createAndUseCredential()

        case .ProvidingCredentialsWithInteraction:
            if self.interacting {
                // interacting with another task, cancel this one
                self.completionHandler(disposition: .CancelAuthenticationChallenge,
                                       credential: nil)
                return
            }
            self.interacting = true
            self.startInteraction {(action: AuthenticationAction) -> Void in
                self.interacting = false
                self.perform(action)
            }
        case .PerformDefaultHandling:
            self.completionHandler(disposition: .PerformDefaultHandling, credential: nil)
        case .RejectProtectionSpace:
            self.completionHandler(disposition: .RejectProtectionSpace, credential: nil)
        case .CancelingConnection:
            self.completionHandler(disposition: .CancelAuthenticationChallenge, credential: nil)
        default:
            assert(false)
        }
    }

/*!
 * @abstract 
 * Perform an action for a specified authentication
 *
 * @param action 
 * The AuthenticationAction is the type of action to perform.
 *
 * @param challenge 
 * The NSURLAuthenticationChallenge to use.
 *
 * @param completionHandler 
 * The AuthenticationCompletionHandler closure to execute when the action is 
 * complete.
 *
 * @param cycle 
 * The Cycle requires authentication.
 */
    public func performAction(action: AuthenticationAction, challenge: NSURLAuthenticationChallenge,
    completionHandler: AuthenticationCompletionHandler, cycle: Cycle) {
        self.challenge = challenge
        self.completionHandler = completionHandler
        self.cycle = cycle

        self.perform(action)
    }

/*!
 * @abstract
 * Determine the action to take for a specified authentication
 *
 * @discussion 
 * The result will be passed to the method performAction as action.
 *
 * @param challenge 
 * The NSURLAuthenticationChallenge to use.
 *
 * @param cycle 
 * The Cycle requires authentication.
 *
 * @result 
 * A AuthenticationAction value.
 */
    public func actionForAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
    cycle: Cycle) -> AuthenticationAction {
        if challenge.previousFailureCount == 0 {
            return .ProvidingCredentials
        }

        return .ProvidingCredentialsWithInteraction;
    }

/*!
 * @abstract 
 * Determine if the Authentication can be used to handle a specified authentication
 *
 * @param challenge 
 * The NSURLAuthenticationChallenge to use.
 *
 * @param cycle 
 * The Cycle requires the authentication handling.
 *
 * @result 
 * true or false. The determination result.
 */
    public func canHandleAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
    cycle: Cycle) -> Bool {
        assert(false)
        return false
    }

    func createAndUseCredential() {
        assert(false)
    }

    func startInteraction(completionHandler: AuthenticationInteractionCompletionHandler) {
        assert(false);
    }
}

/*!
 * @discussion 
 * A Authentication subclass handles the below basic HTTP authentication 
 * challenges:
 *
 * - NSURLAuthenticationMethodHTTPBasic</li>
 * - NSURLAuthenticationMethodHTTPDigest</li>
 * - NSURLAuthenticationMethodNTLM</li>
 *
 * This class could present an alert view for user to input username and password.
 */
public class BasicAuthentication : Authentication {
    var username: String
    var password: String
    var presentingViewController: UIViewController?
    var interactionCompletionHandler: AuthenticationInteractionCompletionHandler! = nil
    let Methods = [NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest,
        NSURLAuthenticationMethodNTLM] // FIXME: use Type Variable

    public init(username: String, password: String) {
        self.username = username
        self.password = password
        super.init()
    }

    convenience override init() {
        self.init(username: "", password: "")
    }

    public override func canHandleAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
        cycle: Cycle) -> Bool {
        var method = challenge.protectionSpace.authenticationMethod
        if (self.Methods as NSArray).containsObject(method!) {
            return true
        }
            
        return false
    }

    override func createAndUseCredential() {
        var credential = NSURLCredential(user: self.username, password: self.password,
                                         persistence: .None)
        self.completionHandler(disposition: .UseCredential, credential: credential)
    }

    override func startInteraction(completionHandler: AuthenticationInteractionCompletionHandler) {
        self.interactionCompletionHandler = completionHandler
        dispatch_async(dispatch_get_main_queue()) {
            assert(self.presentingViewController != nil)
            
            var title = LocalizedString("BasicAuthentication_LoginAlert_Title")
            var message = self.challenge.protectionSpace.host
            var OKTitle = LocalizedString("BasicAuthentication_LoginAlert_OK")
            var cancelTitle = LocalizedString("BasicAuthentication_LoginAlert_Cancel")
            var alertController = UIAlertController(title: title, message: message,
                preferredStyle: .Alert)
            var OKAction = UIAlertAction(title: OKTitle, style: .Default) {
                action in
                var field = alertController.textFields![0] as UITextField
                var username = field.text
                field = alertController.textFields![1] as UITextField
                var password = field.text
                self.username = username
                self.password = password
                self.interactionCompletionHandler(action: .ProvidingCredentials)
            }
            var cancelAction = UIAlertAction(title: cancelTitle, style: .Default) {
                action in
                alertController.dismissViewControllerAnimated(true) {
                    self.interactionCompletionHandler(action: .CancelingConnection)
                    self.interactionCompletionHandler = nil
                }
            }
            alertController.addAction(OKAction)
            alertController.addAction(cancelAction)
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.placeholder = LocalizedString("BasicAuthentication_Login_UsernameField_Placeholder")
            }
            alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.placeholder = LocalizedString("BasicAuthentication_Login_PasswordField_Placeholder")
                textField.secureTextEntry = true
            }
            var cc = UIViewController()
            self.presentingViewController!.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}
