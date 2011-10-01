//
//  ssclThread.h
//  MPlayerX
//
//  Created by tomasen on 11-1-2.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "PlayerController.h"

@interface ssclThread : NSObject 
+(void)pullSubtitle:(PlayerController*)playerController;
+(void)pushSubtitle:(PlayerController*)playerController;
+(void)authAppstore;
+(NSString*)shareMovie:(NSArray*) parameters; // usage: read source code
+(CFDataRef)genAppstoreGuid;
@end
