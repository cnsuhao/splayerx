//
//  AppDelegate.h
//  SPlayerX
//
//  Created by  on 11-9-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BGHUDAppKit/BGHUDAppKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
  BGHUDSliderCell* test_;
}

@property (assign) IBOutlet NSWindow *window;

@end
