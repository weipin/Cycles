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

enum AuthenticationAction {
    case ProvidingCredentials
    case ProvidingCredentialsWithInteraction
    case PerformDefaultHandling
    case RejectProtectionSpace
    case CancelingConnection
}

typealias AuthenticationCompletionHandler = (disposition: NSURLSessionAuthChallengeDisposition,
    credential: NSURLCredential!) -> Void
typealias AuthenticationInteractionCompletionHandler = (action: AuthenticationAction) -> Void


class Authentication {
    var challenge: NSURLAuthenticationChallenge! = nil
    var completionHandler: AuthenticationCompletionHandler! = nil
    weak var cycle: Cycle! = nil
    var interacting = false

    init() {

    }

    func perform(action: AuthenticationAction) {
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

    func performAction(action: AuthenticationAction, challenge: NSURLAuthenticationChallenge,
    completionHandler: AuthenticationCompletionHandler, cycle: Cycle) {
        self.challenge = challenge
        self.completionHandler = completionHandler
        self.cycle = cycle

        self.perform(action)
    }

    func actionForAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
    cycle: Cycle) -> AuthenticationAction {
        if challenge.previousFailureCount == 0 {
            return .ProvidingCredentials
        }

        return .ProvidingCredentialsWithInteraction;
    }

    func canHandleAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
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

class BasicAuthentication : Authentication {
    var username: String
    var password: String
    var presentingViewController: UIViewController?
    var interactionCompletionHandler: AuthenticationInteractionCompletionHandler! = nil
    let Methods = [NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest,
        NSURLAuthenticationMethodNTLM] // TODO: use Type Variable once available

    init(username: String, password: String) {
        self.username = username
        self.password = password
        super.init()
    }

    convenience init() {
        return self.init(username: "", password: "")
    }

    override func canHandleAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
        cycle: Cycle) -> Bool {
        var method = challenge.protectionSpace.authenticationMethod
        println("\(method)")
        if (self.Methods.bridgeToObjectiveC().containsObject(method)) {
            return true
        }
            
        return false
    }

    override func createAndUseCredential() {
        var credential = NSURLCredential.credentialWithUser(self.username,
                                                            password: self.password,
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
                var username = alertController.textFields[0].text
                var password = alertController.textFields[1].text
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
