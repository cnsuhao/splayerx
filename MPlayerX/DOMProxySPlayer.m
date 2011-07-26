//
//  DOMProxySPlayer.m
//  MPlayerX
//
//  Created by Staff_Mac on 5/26/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "DOMProxySPlayer.h"


@implementation DOMProxySPlayer

- (id)delegate
{
  return _delegate;
}

- (void)setDelegate:(id)new_delegate
{
  _delegate = new_delegate;
}
- (void)setHostWebView:(WebView*)new_hostWebView
{
  _hostWebView = new_hostWebView;
}

/* Here is our Objective-C implementation for the JavaScript SPlayer.Call() method.
 api: rev para: '' 获取版本：
 截图: api:snapshoot para: ''
 获取当前影片时间： api:curtime para: ''
 获取影片总时间 api:totaltime para:''
 打开大窗口： api:openoauth para:url
 关闭大窗口: api:closeoauth para:''
 关闭当前窗:（大小窗口内都调这个函数） api:close para:''
 打开一个窗口:(暂时不启用) api:open para:url
*/
- (NSString*) Call:(NSString*)act Arg:(NSString*)arg
{
  NSLog(@"%@ received %@ with message=%@ %@", self, NSStringFromSelector(_cmd), act, arg);
  
  if ([act isEqualToString:@"rev"]) 
    return @"2";
  else if ([act isEqualToString:@"snapshoot"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_snapshot:)])
      return [_delegate dom_snapshot:_hostWebView];
  }
  else if ([act isEqualToString:@"curtime"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_movie_curtime:)])
      return [_delegate dom_movie_curtime:_hostWebView];
  }
  else if ([act isEqualToString:@"totaltime"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_movie_totaltime:)])
      return [_delegate dom_movie_totaltime:_hostWebView];
  }
  else if ([act isEqualToString:@"openoauth"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_window_openoauth:HostWebView:)])
      return [_delegate dom_window_openoauth:arg HostWebView:_hostWebView]; 
  }
  else if ([act isEqualToString:@"closeoauth"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_window_closeoauth:)])
      return [_delegate dom_window_closeoauth:_hostWebView];
  }
  else if ([act isEqualToString:@"close"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_window_close:)])
      return [_delegate dom_window_close:_hostWebView];
  }
  else if ([act isEqualToString:@"open"]) 
  {
    if ([_delegate respondsToSelector:@selector(dom_window_open:HostWebView:)])
      return [_delegate dom_window_open:arg HostWebView:_hostWebView];
  }
  
  return @"";
}


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


@end
