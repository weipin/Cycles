Service methods for creating/starting Cycles
============================================

- To create a cycle without starting, use `cycleForResourceWithIdentifer` or `cycleForResource`.
- To create and start a cycle, use `requestResourceWithIdentifer` or `requestResource`.

The parameter `identifier` will be used to locate an existing Cycle. If found, 
the existing one will be cancelled and then replaced by the new one. The default 
"replacing" behavior can be changed by using option `CycleForResourceOption.Reuse`, 
in which case the existing one will be returned instead and no new Cycle will be 
created.

The "replacing" or "reusing" behavior can be useful if your app only requires 
one "connection" for a specific HTTP task. A good example is "refreshing a 
timeline in an social app", if your app allows user keep tapping the refresh 
button, passing an identifier can prevent the app from creating additional and 
wasteful connections.