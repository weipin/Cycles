Restart
=======

It's easy to "restart" a Cycle because the object holds enough information to
send a request again. "Restart" means Cycles will cancel the request first if
necessary and then resend it. The ability to restart a request can be very
helpful in various situations. For example, if a request fails with an
authentication problem like incorrect key token, you can retain the `Cycle`
somewhere in your app and display an user interface so the user can solve the
authentication problem. Once finished, the `Cycle` can be picked up and
restarted to continue the previous action.
