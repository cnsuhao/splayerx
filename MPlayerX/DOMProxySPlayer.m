//
//  DOMProxySPlayer.m
//  MPlayerX
//
//  Created by Staff_Mac on 5/26/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "DOMProxySPlayer.h"


@implementation DOMProxySPlayer

/* the following three methods are used to determine 
 what methods on our object are exposed to JavaScript */


/* This method is called by the WebView when it is deciding what
 methods on this object can be called by JavaScript.  The method
 should return NO the methods we would like to be able to call from
 JavaScript, and YES for all of the methods that cannot be called
 from JavaScript.
 */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector {
  MPLog(@"%@ received %@ for '%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(selector));
  if (selector == @selector(Call:Arg:)) {
    return NO;
  }
  return YES;
}



/* This method is called by the WebView to decide what instance
 variables should be shared with JavaScript.  The method should
 return NO for all of the instance variables that should be shared
 between JavaScript and Objective-C, and YES for all others.
 */
+ (BOOL)isKeyExcludedFromWebScript:(const char *)property {
  MPLog(@"%@ received %@ for '%s'", self, NSStringFromSelector(_cmd), property);
  if (strcmp(property, "sharedValue") == 0) {
    return NO;
  }
  return YES;
}



/* This method converts a selector value into the name we'll be using
 to refer to it in JavaScript.  here, we are providing the following
 Objective-C to JavaScript name mappings:
 'doOutputToLog:' => 'log'
 'changeJavaScriptText:' => 'setscript'
 With these mappings in place, a JavaScript call to 'console.log' will
 call through to the doOutputToLog: Objective-C method, and a JavaScript call
 to console.setscript will call through to the changeJavaScriptText:
 Objective-C method.  
 
 Comments for the webScriptNameForSelector: method in WebScriptObject.h talk more
 about the default name conversions performed from Objective-C to JavaScript names.
 You can overrride those defaults by providing your own translations in your
 webScriptNameForSelector: method.
 */
+ (NSString *) webScriptNameForSelector:(SEL)sel {
  MPLog(@"%@ received %@ with sel='%@'", self, NSStringFromSelector(_cmd), NSStringFromSelector(sel));
  if (sel == @selector(Call:Arg:)) 
    return @"Call";
  else 
    return nil;
  
}



/* Here is our Objective-C implementation for the JavaScript SPlayer.Call() method.
 */
- (NSString*) Call:(NSString*)act Arg:(NSString*)arg
{
  NSLog(@"%@ received %@ with message=%@ %@", self, NSStringFromSelector(_cmd), act, arg);
  

  return @"2";
}

@end
