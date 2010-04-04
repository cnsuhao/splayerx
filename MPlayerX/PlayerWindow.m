/*
 * MPlayerX - PlayerWindow.m
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

#import "PlayerWindow.h"
#import "TitleView.h"

@implementation PlayerWindow

-(id) initWithContentRect:(NSRect)contentRect 
				styleMask:(NSUInteger)aStyle
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)flag
{
	if (self = [super initWithContentRect:contentRect
								styleMask:NSBorderlessWindowMask
								  backing:bufferingType
									defer:flag]) {
		[self setHasShadow:YES];
		[self setCollectionBehavior:NSWindowCollectionBehaviorManaged];

		[self setContentMinSize:NSMakeSize(400, 300)];
		[self setContentSize:NSMakeSize(400, 300)];
	}
	return self;
}
-(BOOL) canBecomeKeyWindow
{ return YES;}
-(BOOL) canBecomeMainWindow
{ return YES;}

-(void) setTitle:(NSString *)aString
{
	[titlebar setTitle:aString];
	[titlebar setNeedsDisplay:YES];
}
@end
