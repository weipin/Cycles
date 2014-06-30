Auto retry
==========

Cycles will retry a request if one of the following conditions match:

* The connection timed out.
* The response status code is 408 or 503.

Cycles will stop retrying if the retried number exceed the limit. The limit is
controlled by the property `RetryPolicyMaximumRetryCount` of Session. There is
one exception, if the property `solicited` of `Cycle` is true, Cycles will keep
trying for any error until it receives the content.
