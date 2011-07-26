//
//  LauchServiceHandler.h
//  MPlayerX
//
//  Created by Sicheng Zhu on 7/7/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>

#import "LocalizedStrings.h"

extern NSString *const kLaunchServiceDeclinedCount;
extern NSString *const kLaunchServiceNoChecking;
extern NSString *const kLaunchServiceNextAlertDate;

/*
 Your app's name.
 */
#define LAUNCH_SERVICE_APP_NAME [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString*)kCFBundleNameKey]

/*
 Once the rating alert is presented to the user, they might select
 'Remind me later'. This value specifies how long (in days) it
 will wait before reminding them.
 */
#define LAUNCH_SERVICE_TIME_BEFORE_REMINDING 15 // double

/*
 stop the alert after how many times of alert
 */
#define LAUNCH_SERVICE_ALERT_MAX_COUNT  2

/*
 'YES' will show the alert everytime. Useful for testing.
 */
#define LAUNCH_SERVICE_DEBUG NO


@interface LaunchServiceHandler : NSObject

/*
 Tells LauchServiceHandler that the app has launched, the 'uses' count will be 
 incremented. You should call this method at the end of your application delegate's
 application:didFinishLaunchingWithOptions: method.
 by passing NO for canPromptForRating. The setting default alert will simply be postponed
 until it is called again with YES for canPromptForSettingDefault.
 */
+ (void)appLaunched:(BOOL)canPromptForSettingDefault;
- (void)appLaunchedHelp:(NSNumber*)_canPromptForSetting;

/*
 set default action
 called in Preference controller
 */
+ (void)setDefaultAction;

@end

