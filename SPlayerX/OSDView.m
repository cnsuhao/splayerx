//
//  OSDView.m
//  MPlayerX
//
//  Created by Sicheng Zhu on 8/2/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "OSDView.h"

@interface OSDView (OSDViewInternal)
-(void) tryToHide;
@end

@implementation OSDView

@synthesize frontColor;
@synthesize type;

+(void) initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithFloat:kOSDFontSizeMaxDefault], kUDKeyOSDFontSizeMax,
	  [NSNumber numberWithFloat:kOSDFontSizeMinDefault], kUDKeyOSDFontSizeMin,
	  [NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceWhite:1.0 alpha:1.0]], kUDKeyOSDFrontColor,
	  [NSNumber numberWithFloat:kOSDAutoHideTimeIntervalDefault], kUDKeyOSDAutoHideTime,
	  nil]];
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        ud = [NSUserDefaults standardUserDefaults];
        
		autoHideTimeInterval = 0;
		autoHideTimer = nil;
		shouldHide = YES;
        type = kOSDTypeOther;
		
		frontColor = [[NSUnarchiver unarchiveObjectWithData:[ud objectForKey:kUDKeyOSDFrontColor]] retain];
        
		shadow = [[NSShadow alloc] init];
		[shadow setShadowOffset:NSMakeSize(1.0, -1.0)];
		[shadow setShadowColor:[NSColor blackColor]];
		[shadow setShadowBlurRadius:8];
		
		[OSDTextField setAlphaValue:0];
		[OSDTextField setSelectable:NO];
		[OSDTextField setAllowsEditingTextAttributes:YES];
		[OSDTextField setDrawsBackground:NO];
		[OSDTextField setBezeled:NO];
		
		[self setAutoHideTimeInterval:[ud floatForKey:kUDKeyOSDAutoHideTime]];
    }
    
    return self;
}

-(void) dealloc
{
	if (autoHideTimer) {
		[autoHideTimer invalidate];
	}
	[frontColor release];
	[shadow release];
    
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)awakeFromNib
{
    // set OSD active status
    [OSDTextField.animator setAlphaValue:0];
    OSDTextField.stringValue = @"";

}


-(void) setAutoHideTimeInterval:(NSTimeInterval)ti
{
	if (autoHideTimer) {
		[autoHideTimer invalidate];
		autoHideTimer = nil;
	}
	if (ti > 0) {
		autoHideTimeInterval = ti;
		autoHideTimer = [NSTimer timerWithTimeInterval:autoHideTimeInterval/2
												target:self
											  selector:@selector(tryToHide)
											  userInfo:nil
											   repeats:YES];
		NSRunLoop *rl = [NSRunLoop mainRunLoop];
		[rl addTimer:autoHideTimer forMode:NSDefaultRunLoopMode];
		[rl addTimer:autoHideTimer forMode:NSModalPanelRunLoopMode];
		[rl addTimer:autoHideTimer forMode:NSEventTrackingRunLoopMode];
	}
}

-(void) tryToHide
{
	if (shouldHide) {
		[OSDTextField.animator setAlphaValue:0];
		OSDTextField.stringValue = @"";
	} else {
		shouldHide = YES;
	}
}

-(void) setStringValueDelayed:(NSString *)aString
{
	[self setStringValue:aString
                    type:kOSDTypeNotifier
             updateTimer:YES];
	
}

-(void) setStringValue:(NSString *)aString type:(OSDTYPE)tp updateTimer:(BOOL)ut
{
    if (ut || ([OSDTextField alphaValue] > 0 && (tp == type))) {
        if ([[OSDTextField stringValue] length] > 0 && tp == kOSDTypeNotifier)
        {
            [self performSelector:@selector(setStringValueDelayed:) withObject:aString afterDelay:1.0];
            return;
        }
        // 如果是更新timer，那么意味着onwer要更换
        // 如果不更新，那么在self没有隐藏，并且owner一直的情况下更新
        if (!aString) {
            // 如果是nil，那么就用现在的值
            aString = [OSDTextField stringValue];
        }
        
        /* bug fixing: OSD won't set front size until window size updated
         */
        if (tp ==  kOSDTypeNotifier)
        {
            NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 0.3];
            [NSThread sleepUntilDate:future];
        }
            
        NSSize sz = [[self superview] bounds].size;
            
        float fontSizeMin = [ud floatForKey:kUDKeyOSDFontSizeMin];
        float fontSizeMax = [ud floatForKey:kUDKeyOSDFontSizeMax];
        float fontSizeRatio = (fontSizeMax - fontSizeMin) / 600.0;
        float fontSizeOffset = (3*fontSizeMin - fontSizeMax) / 2.0;
            
        float fontSize = MIN(fontSizeMax, MAX(fontSizeMin, (sz.height*fontSizeRatio) + fontSizeOffset));
        if (tp == kOSDTypeMediaInfo) 
            fontSize *= 0.7;
        else if (tp == kOSDTypeNotifier)
            fontSize *= 0.7;
        else if (tp == kOSDTypeSubSearch)
            fontSize *= 0.7;
        else
            fontSize *= 0.8;
        NSFont *font = [NSFont systemFontOfSize:fontSize];
			
        NSDictionary *attrDict = [[NSDictionary alloc] initWithObjectsAndKeys:
									  font, NSFontAttributeName,
									  frontColor, NSForegroundColorAttributeName,
									  shadow, NSShadowAttributeName, nil];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:aString attributes:attrDict];
        [OSDTextField setObjectValue:str];
			
        [OSDTextField setAlphaValue:1];
			
        [str release];
        [attrDict release];			
    }
    if (ut) {
        // 如果更新Timer的话，那么更新owner
        type = tp;
        shouldHide = NO;
    }

}


@end
