//
//  DOMProxySPlayer.h
//  MPlayerX
//
//  Created by Staff_Mac on 5/26/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface DOMProxySPlayerDelegate : NSObject

- (NSString*)dom_snapshot:(WebView *)hostWebView;
- (NSString*)dom_movie_curtime:(WebView *)hostWebView;
- (NSString*)dom_movie_totaltime:(WebView *)hostWebView;
- (NSString*)dom_window_closeoauth:(WebView *)hostWebView;
- (NSString*)dom_window_close:(WebView *)hostWebView;
- (NSString*)dom_window_open:(NSString*)url HostWebView:(WebView *)hostWebView;
- (NSString*)dom_window_openoauth:(NSString*)url HostWebView:(WebView *)hostWebView;

@end

@interface DOMProxySPlayer : NSObject {
  id _delegate;
  WebView* _hostWebView;
}

- (id)delegate;
- (void)setDelegate:(id)new_delegate;
- (void)setHostWebView:(WebView*)new_hostWebView;

/* WebScripting methods */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;
+ (BOOL)isKeyExcludedFromWebScript:(const char *)property;
+ (NSString *) webScriptNameForSelector:(SEL)sel;

/* methods we're sharing with JavaScript */
- (NSString*) Call:(NSString*)act Arg:(NSString*)arg;

@end
