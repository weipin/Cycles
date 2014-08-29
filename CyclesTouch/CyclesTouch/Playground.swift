//
//  Playground.swift
//  CyclesTouch
//
//  Created by Weipin Xia on 8/3/14.
//  Copyright (c) 2014 Cocoahope. All rights reserved.
//

import Foundation

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

//        var URLString = "http://127.0.0.1:8000/test/echo?content=helloworld"
//        Cycle.download(URLString,
//            didWriteDataHandler: {
//                (cycle, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//                // handle progress
//
//            },
//            downloadFileHandler: {(cycle, location) in
//                var content = NSString(contentsOfURL: location, encoding: NSUTF8StringEncoding, error: nil)
//                println("\(content)") // helloworld
//            },
//            completionHandler: {(cycle, error) in
//                // check error
//            })

//        var foo = FooService()
//        foo.requestResource("hello", URIValues: ["content": "hello world"],
//            completionHandler: { (cycle, error) in
//                println("\(cycle.response.text)");
//            })

//        var service = FooTestMoreService()
//        service.requestResource("postjson", requestObject: ["k1": "v1"],
//            completionHandler: { (cycle, error) in
//                var dict = cycle.response.object as Dictionary<String, String>
//                var value = dict["k1"]!
//                println("\(value)")
//            })

//var dict = NSMutableDictionary(object: "last1", forKey: "lastName")
//KeyValueObservingCenter.sharedInstance.addObserver(self, keyPath: "lastName",
//    options: .New, context: nil, observed:dict, queue: NSOperationQueue .mainQueue()) {
//        keyPath, observed, change, context in
//        var lastName: AnyObject? = change[NSKeyValueChangeNewKey]
//        var result = lastName as String
//}
//dict.setValue("last2", forKey: "lastName")
//

//var service = GitHub()
//service.requestResource("user",
//    completionHandler: { (cycle, error) in
//        println("\(cycle.response.statusCode)")
//        var header = cycle.response.valueForHTTPHeaderField("content-type")
//        println("\(header)")
//        println("\(cycle.response.textEncoding)")
//        println("\(cycle.response.text)")
//        println("\(cycle.response.object)")
//    })

//class FooModel: Model {
//    var date: NSDate {
//        get {
//            return self.dict["Date"] as NSDate
//        }
//
//        set {
//            self.dict["Date"] = newValue
//        }
//    }
//}
//
//@objc (FooTransformer)
//class FooTransformer: ObjectTransformer {
//    // must override
//    override class func objectForMapping() -> AnyObject {
//        return FooModel(dict: Dictionary<String, AnyObject>())
//    }
//
//    // must override
//    override class func mappingMeta() -> ObjectMappingMeta {
//        return ObjectMappingMeta.metaForName("FooModel")!
//    }
//}
//
//@objc (FooListTransformer)
//class FooListTransformer: ObjectListTransformer {
//    override class func objectForMapping() -> AnyObject {
//        return FooModel(dict: Dictionary<String, AnyObject>())
//    }
//
//    override class func mappingMeta() -> ObjectMappingMeta {
//        return ObjectMappingMeta.metaForName("FooModel")!
//    }
//}

//// single date field
//var meta = ObjectMappingMeta.metaForName("FooModel")
//var data = ["Date": "2014-05-28T08:35:37"]
//var object = NSMutableDictionary()
//updateObject(object, fromData: data, withMeta: meta!)
//println("\(object)")
//
//var dict = NSMutableDictionary()
//updateData(dict, fromObject: object, withMeta: meta!)
//println("\(dict)")
//
//// object mapping
//meta = ObjectMappingMeta.metaForName("ContainerModel")
//var data1 = ["Foo": ["Date": "2014-05-28T08:35:37"]]
//object = NSMutableDictionary()
//updateObject(object, fromData: data1, withMeta: meta!)
//println("\(object)")
//
//dict = NSMutableDictionary()
//updateData(dict, fromObject: object, withMeta: meta!)
//println("\(dict)")
//
//// object list mapping
//meta = ObjectMappingMeta.metaForName("ContainerModel")
//var data2 = ["FooList": [["Date": "2014-05-28T08:35:37"], ["Date": "2014-05-29T01:31:31"]]]
//object = NSMutableDictionary()
//updateObject(object, fromData: data2, withMeta: meta!)
//println("\(object)")
//
//dict = NSMutableDictionary()
//updateData(dict, fromObject: object, withMeta: meta!)
//println("\(dict)")

