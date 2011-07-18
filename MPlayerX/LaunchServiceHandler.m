//
//  LauchServiceHandler.m
//  MPlayerX
//
//  Created by Sicheng Zhu on 7/7/11.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "LaunchServiceHandler.h"

NSString *const kLaunchServiceDeclinedCount = @"kLaunchServiceDeclinedCount";
NSString *const kLaunchServiceNoChecking = @"kLaunchServiceeNoChecking";
NSString *const kLaunchServiceNextAlertDate = @"kLaunchServiceNextAlertDate";

@interface LaunchServiceHandler (hidden)
+ (LaunchServiceHandler *)sharedInstance;
+ (BOOL)isDefaultPlayer;
+ (void)setDefault;
- (void)showAlert;
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end

@implementation LaunchServiceHandler (hidden)

+ (LaunchServiceHandler *)sharedInstance {
    static LaunchServiceHandler *lshandler = nil;
    if (lshandler == nil)
    {
        @synchronized(self) {
            if (lshandler == nil)
                lshandler = [[LaunchServiceHandler alloc] init];
        }
    }
    return lshandler;
}

+ (BOOL)isDefaultPlayer
{
    BOOL isDefaultPlayer = YES;
    
    NSArray *UTIArr;
    UTIArr = [NSArray arrayWithObjects:
              // build-in UTI
              @"public.3gpp2",
              @"public.3gpp",
              @"public.avi",
              @"com.apple.quicktime-movie",
              @"public.mpeg-4",
              @"public.mpeg",
              // imported UTI
              @"com.real.realmedia",
              @"com.microsoft.windows-media-wmv",
              // exported UTI
              @"org.splayer.splayerx.asf",
              @"org.splayer.splayerx.asx",
              @"org.splayer.splayerx.dat",
              @"org.splayer.splayerx.divx",
              @"org.splayer.splayerx.dv",
              @"org.splayer.splayerx.f4v",
              @"org.splayer.splayerx.flv",
              @"org.splayer.splayerx.m2ts",
              @"org.splayer.splayerx.m2t",
              @"org.splayer.splayerx.m4v",
              @"org.splayer.splayerx.mjp",
              @"org.splayer.splayerx.mkv",
              @"org.splayer.splayerx.mpg2",
              @"org.splayer.splayerx.mts",
              @"org.splayer.splayerx.mtv",
              @"org.splayer.splayerx.mxf",
              @"org.splayer.splayerx.ogm",
              @"org.splayer.splayerx.ogc",
              @"org.splayer.splayerx.qtz",
              @"org.splayer.splayerx.rmvb",
              @"org.splayer.splayerx.rv",
              @"org.splayer.splayerx.swf",
              @"org.splayer.splayerx.ts",
              @"org.splayer.splayerx.tp",
              @"org.splayer.splayerx.vc1",
              @"org.splayer.splayerx.vcd",
              @"org.splayer.splayerx.vob",
              @"org.splayer.splayerx.vro",
              @"org.splayer.splayerx.webm",
              @"org.splayer.splayerx.xvid",
              @"org.splayer.splayerx.yuv",
              nil];
    
    NSEnumerator *myEnumerator = [UTIArr objectEnumerator];
    NSString *tempUTIName;
    NSString *tempStr;
    while (tempUTIName = [myEnumerator nextObject]) {
        tempStr = (NSString *)LSCopyDefaultRoleHandlerForContentType ((CFStringRef)tempUTIName, kLSRolesViewer);
        if (![tempStr isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) isDefaultPlayer = NO;
    }
        
    return isDefaultPlayer;
}

+ (void)setDefault
{
    NSArray *UTIArr;
    UTIArr = [NSArray arrayWithObjects:
              // build-in UTI
              @"public.3gpp2",
              @"public.3gpp",
              @"public.avi",
              @"com.apple.quicktime-movie",
              @"public.mpeg-4",
              @"public.mpeg",
              // imported UTI
              @"com.real.realmedia",
              @"com.microsoft.windows-media-wmv",
              // exported UTI
              @"org.splayer.splayerx.asf",
              @"org.splayer.splayerx.asx",
              @"org.splayer.splayerx.dat",
              @"org.splayer.splayerx.divx",
              @"org.splayer.splayerx.dv",
              @"org.splayer.splayerx.f4v",
              @"org.splayer.splayerx.flv",
              @"org.splayer.splayerx.m2ts",
              @"org.splayer.splayerx.m2t",
              @"org.splayer.splayerx.m4v",
              @"org.splayer.splayerx.mjp",
              @"org.splayer.splayerx.mkv",
              @"org.splayer.splayerx.mpg2",
              @"org.splayer.splayerx.mts",
              @"org.splayer.splayerx.mtv",
              @"org.splayer.splayerx.mxf",
              @"org.splayer.splayerx.ogm",
              @"org.splayer.splayerx.ogc",
              @"org.splayer.splayerx.qtz",
              @"org.splayer.splayerx.rmvb",
              @"org.splayer.splayerx.rv",
              @"org.splayer.splayerx.swf",
              @"org.splayer.splayerx.ts",
              @"org.splayer.splayerx.tp",
              @"org.splayer.splayerx.vc1",
              @"org.splayer.splayerx.vcd",
              @"org.splayer.splayerx.vob",
              @"org.splayer.splayerx.vro",
              @"org.splayer.splayerx.webm",
              @"org.splayer.splayerx.xvid",
              @"org.splayer.splayerx.yuv",
              nil];
    
    NSEnumerator *myEnumerator = [UTIArr objectEnumerator];
    NSString *tempUTIName;
    while (tempUTIName = [myEnumerator nextObject]) {
        LSSetDefaultRoleHandlerForContentType ((CFStringRef)tempUTIName,
                                               kLSRolesViewer,
                                               (CFStringRef)[[NSBundle mainBundle] bundleIdentifier]);
    }
}

- (void)showAlert {
    NSAlert *alert = [NSAlert alertWithMessageText:kMPXStringSetDefaultAlertTitle
                                     defaultButton:kMPXStringSetDefaultDefaultButton
                                   alternateButton:kMPXStringSetDefaultRejectButton
                                       otherButton:kMPXStringSetDefaultRemindLaterButton
                         informativeTextWithFormat:
                      [NSString stringWithFormat:kMPXStringSetDefaultAlertMessage, LAUNCH_SERVICE_APP_NAME] ];
    
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                      modalDelegate:self
                     didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
}


- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    switch (returnCode) {
        case NSAlertAlternateReturn:
        {
            // customer don't want to set it default
            [ud setInteger:([ud integerForKey:kLaunchServiceDeclinedCount]+1) forKey:kLaunchServiceDeclinedCount];
            [ud setObject:[NSDate dateWithTimeIntervalSinceNow:(LAUNCH_SERVICE_TIME_BEFORE_REMINDING  * 3600 * 24)] 
                   forKey:kLaunchServiceNextAlertDate];
            break;
        }
        case NSAlertDefaultReturn:
        {
            // customer want to set it default
            [LaunchServiceHandler setDefault];
            [ud setInteger:0 forKey:kLaunchServiceDeclinedCount];
            break;
        }
        case NSAlertOtherReturn:
            // remind them later
            break;
        default:
            break;
    }
    
    [ud synchronize];
    
    [self release];
}

@end


@implementation LaunchServiceHandler
- (void)appLaunchedHelp:(NSNumber *)_canPromptForSetting
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // initialization
    if ([ud objectForKey:kLaunchServiceNextAlertDate] == nil)
    {
        [ud setObject:[NSDate date] forKey:kLaunchServiceNextAlertDate];
        [ud setInteger:0 forKey:kLaunchServiceDeclinedCount];
        [ud setBool:NO forKey:kLaunchServiceNoChecking];
        [ud synchronize];
    }
    
    if (LAUNCH_SERVICE_DEBUG || (
                                 ([_canPromptForSetting boolValue] == YES) && 
                                 (![ud boolForKey:kLaunchServiceNoChecking]) &&
                                 (![LaunchServiceHandler isDefaultPlayer]) && 
                                 ([[ud objectForKey:kLaunchServiceNextAlertDate] timeIntervalSinceNow] <= 0) &&
                                 ([ud integerForKey:kLaunchServiceDeclinedCount] < LAUNCH_SERVICE_ALERT_MAX_COUNT)
                                 ))
        [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
    
	[pool release];
}

+ (void)appLaunched:(BOOL)canPromptForSetting
{
    NSNumber *_canPromptForSetting = [[NSNumber alloc] initWithBool:canPromptForSetting];
	[NSThread detachNewThreadSelector:@selector(appLaunchedHelp:)
                             toTarget:[LaunchServiceHandler sharedInstance]
                           withObject:_canPromptForSetting];
    
	[_canPromptForSetting release];
}

+ (void)setDefaultAction
{
    [self setDefault];
}

@end