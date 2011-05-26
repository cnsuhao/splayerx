//
//  DOMProxySPlayer.h
//  MPlayerX
//
//  Created by Staff_Mac on 5/26/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DOMProxySPlayer : NSObject {
}
/* WebScripting methods */
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;
+ (BOOL)isKeyExcludedFromWebScript:(const char *)property;
+ (NSString *) webScriptNameForSelector:(SEL)sel;

/* methods we're sharing with JavaScript */
- (NSString*) Call:(NSString*)act Arg:(NSString*)arg;

@end
