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


class Authentication : NSObject {
    var challenge: NSURLAuthenticationChallenge! = nil
    var completionHandler: AuthenticationCompletionHandler! = nil
    weak var cycle: Cycle! = nil
    var interacting = false

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
            self.startInteraction {[unowned self] (action: AuthenticationAction) -> Void in
                self.interacting = false
                assert(action != .ProvidingCredentialsWithInteraction)
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

class BasicAuthentication : Authentication, UIAlertViewDelegate {
    var username = ""
    var password = ""
    var interactionCompletionHandler: AuthenticationInteractionCompletionHandler! = nil
    let Methods = [NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest,
        NSURLAuthenticationMethodNTLM] // TODO: use Type Variable once available

    override func canHandleAuthenticationChallenge(challenge: NSURLAuthenticationChallenge,
        cycle: Cycle) -> Bool {
        var method = challenge.protectionSpace.authenticationMethod
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

        var title = LocalizedString("BasicAuthentication_LoginAlert_Title")
        var message = self.challenge.protectionSpace.host
        var alertView = UIAlertView(title: title, message: message,
                                    delegate: self,
                                    cancelButtonTitle: LocalizedString("BasicAuthentication_LoginAlert_Cancel"),
                                    otherButtonTitles: LocalizedString("BasicAuthentication_LoginAlert_OK"))
        alertView.alertViewStyle = .LoginAndPasswordInput
        alertView.show()
    }

    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            self.interactionCompletionHandler(action: .CancelingConnection)
            self.interactionCompletionHandler = nil
            return
        }

        self.username = alertView.textFieldAtIndex(0).text
        self.password = alertView.textFieldAtIndex(1).text
        self.interactionCompletionHandler(action: .ProvidingCredentials)
    }
}
