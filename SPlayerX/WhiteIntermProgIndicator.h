//
//  WhiteIntermProgIndicator.h
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

#import <Cocoa/Cocoa.h>

@interface WhiteIntermProgIndicator : NSProgressIndicator {
	BOOL spinning;
}

- (BOOL)isSpinning;
- (void)setSpinning:(BOOL)value;


@end
