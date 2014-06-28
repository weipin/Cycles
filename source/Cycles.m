//
//  Cycles.m
//
//  Copyright (c) 2014 Weipin Xia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "Cycles.h"

/*
 https://www.mikeash.com/pyblog/friday-qa-2009-08-14-practical-blocks.html
 */
@implementation NSObject (CyclesBridging)

- (void)cyclesbridging_callBlock {
    void (^block)(void) = (id)self;
    block();
}

@end

void RunOnThread(NSThread *thread, BOOL wait, void (^block)(void)) {
    [block performSelector:@selector(cyclesbridging_callBlock)
                  onThread:thread
                withObject:nil
             waitUntilDone:wait];
}

// http://www.mikeash.com/pyblog/friday-qa-2011-07-22-writing-unit-tests.html
BOOL WaitForWithTimeout(NSTimeInterval timeout, BOOL (^block)(void)) {
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while(!block() && [[NSProcessInfo processInfo] systemUptime] - start <= timeout) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    }
    return block();
}

