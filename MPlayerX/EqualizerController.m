/*
 * MPlayerX - EqualizerController.m
 *
 * Copyright (C) 2009 Zongyao QU
 * 
 * MPlayerX is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * MPlayerX is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with MPlayerX; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "def.h"
#import "EqualizerController.h"
#import "PlayerController.h"

@interface EqualizerController (Internal)
-(void) playBackWillStop:(NSNotification*)notif;
@end

@implementation EqualizerController

-(id) init
{
	if (self = [super init]) {
		nibLoaded = NO;
	}
	return self;
}

-(void) dealloc
{	
	[super dealloc];
}

-(void) awakeFromNib
{
	if (!nibLoaded) {
		[menuEQPanel setKeyEquivalent:kSCMEqualizerPanelKeyEquivalent];
		[menuEQPanel setKeyEquivalentModifierMask:kSCMEqualizerPanelKeyEquivalentModifierFlagMask];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackWillStop:)
												 name:kMPCPlayWillStopNotification object:playerController];

}

-(IBAction) showUI:(id)sender
{
	if (!nibLoaded) {
		nibLoaded = YES;
	}
}

-(IBAction) setEqualizer:(id)sender
{
	[playerContrller setEqualizer:[sender cells]];
}

-(void) playBackWillStop:(NSNotification*)notif
{
	
}

@end