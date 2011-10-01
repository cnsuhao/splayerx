//
//  WhiteIntermProgIndicator.m
//  WhiteIntermProgIndicator
//
//  Created by Dallas Brown on 12/23/08.
//  http://www.CodeGenocide.com
//  Copyright 2008 Code Genocide. All rights reserved.
//
//  Based off of AMIndeterminateProgressIndicatorCell created by Andreas, version date 2007-04-03.
//  http://www.harmless.de
//  Copyright 2007 Andreas Mayer. All rights reserved.
//

#import "WhiteIntermProgIndicator.h"

#define DEG2RAD  0.017453292519943295

@implementation WhiteIntermProgIndicator

#define degreesToRadians(x) (DEG2RAD * x)

- (id)init
{ 
  self = [super init];
  
	return self;
}

- (BOOL)isSpinning
{
	return spinning;
}

- (void)drawRect:(NSRect)dirtyRect 
{ 
  if ([self isSpinning] || [self isDisplayedWhenStopped]) {
		float flipFactor = ([self isFlipped] ? 1.0 : -1.0);
		int step = round([self doubleValue]/(5.0/60.0));
		float cellSize = MIN(dirtyRect.size.width, dirtyRect.size.height);
		NSPoint center = dirtyRect.origin;
		center.x += cellSize/2.0;
		center.y += dirtyRect.size.height/2.0;
		float outerRadius;
		float innerRadius;
		float strokeWidth = cellSize*0.08;
		if (cellSize >= 32.0) {
			outerRadius = cellSize*0.44;
			innerRadius = cellSize*0.27;
		} else {
			outerRadius = cellSize*0.48;
			innerRadius = cellSize*0.37;
		}
		float a; // angle
		NSPoint inner;
		NSPoint outer;
		[NSBezierPath setDefaultLineCapStyle:NSRoundLineCapStyle];
                                        //NSButtLineCapStyle
		[NSBezierPath setDefaultLineWidth:strokeWidth];
		if ([self isSpinning]) {
			a = (270+(step* 30))*DEG2RAD;
		} else {
			a = 270*DEG2RAD;
		}
		a = flipFactor*a;
		int i;
    
		for (i = 0; i < 12; i++)
		{
			if (i == 0)
			{
				[[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] set];
			}
			else
			{
				[[NSColor colorWithCalibratedWhite:MIN(sqrt(i)*0.5, 0.8) alpha:1.0] set];
			}
			
			outer = NSMakePoint(center.x+cos(a)*outerRadius, center.y+sin(a)*outerRadius);
			inner = NSMakePoint(center.x+cos(a)*innerRadius, center.y+sin(a)*innerRadius);
			[NSBezierPath strokeLineFromPoint:inner toPoint:outer];
			a -= flipFactor*30*DEG2RAD;
		}
	}
}

- (void)dealloc
{

	[super dealloc];
}

@end
