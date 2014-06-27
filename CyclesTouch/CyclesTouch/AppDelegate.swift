//
//  AppDelegate.swift
//  CyclesTouch
//
//  Created by Weipin Xia on 6/21/14.
//  Copyright (c) 2014 Cocoahope. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        self.window!.backgroundColor = UIColor.whiteColor()
        self.window!.rootViewController = UIViewController()
        self.window!.makeKeyAndVisible()

//        var URL = NSURL(string: "http://127.0.0.1:8000/test/hello")
//        var cycle = Cycle(requestURL: URL)
//        cycle.start {(cycle, error) in
//            var text = cycle.response.text
//        }
//
//        var data = "Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
//        var URL = NSURL(string: "http://127.0.0.1:8000/test/dumpupload/")
//        var cycle = Cycle(requestURL: URL, taskType: .Upload, requestMethod: "POST")
//        cycle.dataToUpload = data
//        cycle.start {(cycle, error) in
//            var t = cycle.response.text
//            println("\(t)")
//        }
//
//        Cycle.get("http://127.0.0.1:8000/test/echo/",
//                  parameters: ["content": ["helloworld"]],
//            completionHandler: {(cycle, error) in
//                var text = cycle.response.text
//                println(text)
//            })

//        var auth = BasicAuthentication()
//        auth.presentingViewController = self.window!.rootViewController
//        Cycle.get("http://127.0.0.1:8000/test/hello_with_basic_auth/",
//            authentications: [auth], completionHandler: {
//                (cycle, error) in
//                var text = cycle.response.text
//                println("\(text)")
//            })

        Cycle.get("https://api.github.com/user",
            requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
            responseProcessors: [JSONProcessor()],
            completionHandler: { (cycle, error) in
                println("\(cycle.response.statusCode)")
                var header = cycle.response.valueForHTTPHeaderField("content-type")
                println("\(header)")
                println("\(cycle.response.textEncoding)")
                println("\(cycle.response.text)")
                println("\(cycle.response.object)")
            })

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

