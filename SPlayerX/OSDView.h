//
//  OSDView.h
//  MPlayerX
//
//  Created by Sicheng Zhu on 8/2/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "UserDefaults.h"
#import "LocalizedStrings.h"
#import "StoreHandler.h"

#define kOSDAutoHideTimeIntervalDefault	5

#define kOSDFontSizeMinDefault          24
#define kOSDFontSizeMaxDefault          48

typedef enum
{
    kOSDTypeTime = 1,
    kOSDTypeMediaInfo = 2,
    kOSDTypeCoreControl = 3,
    kOSDTypeNotifier = 4,
    kOSDTypeSubSearch = 5,
    kOSDTypeOther = 6
} OSDTYPE;

@interface OSDView : NSView
{
    IBOutlet NSTextField *OSDTextField;
    
    NSUserDefaults *ud;
    OSDTYPE type;
    
    // data for text field
	BOOL shouldHide;
	NSColor *frontColor;
	NSShadow *shadow;
    
	NSTimer *autoHideTimer;
	NSTimeInterval autoHideTimeInterval;
    
    //data for renew button
}

@property (retain, readwrite) NSColor *frontColor;
@property (readonly) OSDTYPE type;

-(void) setAutoHideTimeInterval:(NSTimeInterval)ti;
-(void) setStringValue:(NSString *)aString type:(OSDTYPE)tp updateTimer:(BOOL)ut;

@end
