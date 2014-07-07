.. _auto_retry_label:

Auto retry
==========

Cycles will retry a request if one of the following conditions matches:

* The connection timed out.
* The response status code is 408 or 503.

Cycles will stop retrying if the retried number exceeds the limit. The limit is
controlled by the property `RetryPolicyMaximumRetryCount` of Session. There is
one exception -- if the property `solicited` of `Cycle` is true, Cycles will keep
trying for any error until it receives the content without attempt limit.

There is also a delay before a new retry can be attempted. The interval is
controlled by the property `retryDelay` of `Session`.
