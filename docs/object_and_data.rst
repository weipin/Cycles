.. _object_and_data_label:

The relationship between property `object` and property `data`
==============================================================

Both `Request` and `Response` have property `object` and property `data`.

The property `object` represents a model object, depends on your requirements, it
can be any type. For `Request`, the `object` will be used to create request data.
For `Response`, the `object` will be used to store the model converted from
response content.

The property `data` represents the raw data, the type is NSData. For `Request`,
the `data` is the request body to send. For `Response`, the `data` is the
response content received.

The conversion between `object` and `data` is performed by the Processor objects
(`requestProcessors`). For `Request`, the Processors will convert the `object`
into `data`. For `Response`, the Processors (responseProcessors) will convert
the `data` into `object`.
