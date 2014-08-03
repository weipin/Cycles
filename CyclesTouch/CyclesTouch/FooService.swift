//
//  FooService.swift
//  CyclesTouch
//
//  Created by Weipin Xia on 8/3/14.
//  Copyright (c) 2014 Cocoahope. All rights reserved.
//

import Foundation

class FooService: Service {
    override class func className() -> String {
        return "FooService"
    }

    override func defaultSession() -> Session {
        return Session()
    }

    override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
    }

}

class FooTestMoreService: Service {
    override class func className() -> String {
        return "FooTestMoreService"
    }

    override func defaultSession() -> Session {
        var session = super.defaultSession()
        session.requestProcessors = [JSONProcessor()]
        session.responseProcessors = [JSONProcessor()]

        return session
    }

    override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
    }
    
}

class GitHub: Service {
    override class func className() -> String {
        return "GitHub"
    }

    override func defaultSession() -> Session {
        var session = super.defaultSession()
        session.requestProcessors = [BasicAuthProcessor(username: "user", password: "pass")]
        session.responseProcessors = [JSONProcessor()]

        return session
    }

    override func cycleDidCreateWithResourceName(cycle: Cycle, name: String) {
    }
    
}