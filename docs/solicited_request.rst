Solicited request
=================

`Solicited request` and `unsolicited request` is more of an user interface
concept. A `solicited request` is an operation specifically issued by the user,
like tapping a button to reload a list. In such case, if there is any error
happens while fetching the content, it's ideal for your app to keep retrying
until it succeeds. The solicited state is represented by the property
`solicited` of `Cycle`. If the value of `solicited` is true, Cycles will keep
retrying the request until it receives the content.

Most of the convenient methods accept a parameter `solicited`.
