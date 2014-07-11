Create your own processors
==========================

You can create your own processors to fit your requirements. For example, you
can create a Processor subclass to handle specific authentication types (adding
headers or appending query). Or, you can create a Processor subclass to process
response content with a specific format.

To create your own processors, you subclass `Processor`. There are two methods to
override, `func processRequest(request: Request, error: NSErrorPointer) -> Bool`
and `func processResponse(response: Response, error: NSErrorPointer) -> Bool`.
You don't have to override both if one of the methods is never going to be used.
