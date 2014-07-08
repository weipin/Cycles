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

//        var auth = BasicAuthentication()
//        auth.presentingViewController = self.window!.rootViewController
//        Cycle.get("http://127.0.0.1:8000/test/hello_with_basic_auth/",
//            authentications: [auth], completionHandler: {
//                (cycle, error) in
//                var text = cycle.response.text
//                println("\(text)")
//            })

//        Cycle.get("https://api.github.com/user",
//            requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
//            responseProcessors: [JSONProcessor()],
//            completionHandler: { (cycle, error) in
//                println("\(cycle.response.statusCode)")
//                var header = cycle.response.valueForHTTPHeaderField("content-type")
//                println("\(header)")
//                println("\(cycle.response.textEncoding)")
//                println("\(cycle.response.text)")
//                println("\(cycle.response.object)")
//            })

//        Cycle.post("http://127.0.0.1:8000/test/dumpupload/",
//            requestObject: "Hello World".dataUsingEncoding(NSUTF8StringEncoding),
//            requestProcessors: [DataProcessor()],
//            completionHandler: {
//                (cycle, error) in
//                println("\(cycle.response.text)") // Hello World
//            })

//        var URL = NSURL(string: "http://127.0.0.1:8000/test/dumpupload/")
//        var cycle = Cycle(requestURL: URL, requestMethod: "POST")
//        cycle.request.data = "Hello World".dataUsingEncoding(NSUTF8StringEncoding)
//        cycle.start {
//            (cycle, error) in
//            println("\(cycle.response.text)") // Hello World
//        }

//        Cycle.get("http://www.apple.com/404/",
//            completionHandler: {cycle, error in
//                println("\(error!.domain)") // CycleError
//                println("\(CycleErrorCode.fromRaw(error!.code))") // 2
//                println("\(cycle.response.statusCode)") // 2
//            })

//        var URLString = MergeParametersToURL("http://httpbin.org/get?key2=value2", ["key1": ["value1"]])
//        println(URLString)
//        var URL = MergeParametersToURL("http://domain.com?k1=v1&K2=v2", ["k3": ["v3"]]);
//        println(URL)

//        var URL = NSURL(string: "https://github.com/timeline.json")
//        var cycle = Cycle(requestURL: URL)
//        cycle.request.core.setValue("Cycles/0.01", forHTTPHeaderField: "User-Agent")

//        var auth = BasicAuthentication(username: "test", password: "12345")
//        Cycle.get("http://127.0.0.1:8000/test/hello_with_basic_auth",
//            authentications: [auth],
//            completionHandler: {
//                (cycle, error) in
//                println("\(cycle.response.text)") // Hello World
//            })

//
//        Cycle.upload("http://127.0.0.1:8000/test/dumpupload/",
//            file: NSURL(string: ""),
//            didSendBodyDataHandler: {
//                (cycle, bytesSent, totalBytesSent, totalBytesExpectedToSend) in
//                // handle progress
//            },
//            completionHandler: {
//                (cycle, error) in
//                println("\(cycle.response.text)") // Hello World
//            })
//        var session = Session()
//

        Cycle.get("http://127.0.0.1:8000/test/hello",
            completionHandler: {cycle, error in
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

