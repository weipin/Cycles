#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Cycles"
  s.version          = "0.2.3"
  s.summary          = "HTTP library written in Swift."
  s.description      = <<-DESC
                       Cycles is a HTTP library written in Swift, inspired by [AFNetworking](http://afnetworking.com/)
                       and [Requests](http://docs.python-requests.org/). The target of Cycles is to
                       free you from writing glue code around the NSURLSession classes.

                       ```
                       Cycle.get("https://api.github.com/user/",
                           requestProcessors: [BasicAuthProcessor(username: "user", password: "pass")],
                           responseProcessors: [JSONProcessor()],
                           completionHandler: { (cycle, error) in
                              println("\(cycle.response.statusCode)") // 200
                              var header = cycle.response.valueForHTTPHeaderField("content-type")
                              println("\(header)") // application/json; charset=utf-8
                              println("\(cycle.response.textEncoding)") // 4
                              println("\(cycle.response.text)") // {"login":"user","id":3 ...
                              println("\(cycle.response.object)") // {"avatar_url" = ...
                           })
                       ```

                       Cycles offers a set of higher-level objects. With these objects, there is no
                       need to manually build query strings, or to create collection objects from
                       JSON response. More importantly, Cycles is designed in a way to help you build
                       HTTP functionality into your model layer. Also, properties like `solicited`
                       encourage you to build delightful user experiences.
                       DESC
  s.homepage         = "https://github.com/weipin/Cycles"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Weipin Xia" => "weipin@me.com" }
  s.source           = { :git => "https://github.com/weipin/Cycles.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'source/*'

  s.documentation_url = 'https://cycles.readthedocs.org/'
end
