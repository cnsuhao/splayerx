//
//  ssclThread.m
//  MPlayerX
//
//  Created by tomasen on 11-1-2.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "ssclThread.h"
#import "CocoaAppendix.h"
#import "LocalizedStrings.h"
#import "UserDefaults.h"
#import <WebKit/WebKit.h>
#import "ControlUIView.h"

@implementation ssclThread

+(void) initialize
{
	
	[[NSUserDefaults standardUserDefaults] 
	 registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                     [NSNumber numberWithUnsignedInt:0], kUDKeyNextSVPauthTime,
                     [NSNumber numberWithInt:0], kUDKeySVPLanguage,
                     nil]];  
}
                     
+(void)pullSubtitle:(PlayerController*)playerController 
{

    [self authAppstore];
  
	NSAutoreleasePool* POOL = [[NSAutoreleasePool alloc] init];	
	// send osd
	if (![playerController.lastPlayedPath isFileURL])
		return [POOL release];
    
    // add IAP expire reminder on OSD
    dispatch_async(dispatch_get_main_queue(), ^{
        [playerController setOSDMessage:kMPXStringSSCLFetching type:kOSDTypeSubSearch];
    });
	
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	NSString* argLang = @"chn";
	NSString* langCurrent = [[ud objectForKey:@"AppleLanguages"] objectAtIndex:0];
	if ([langCurrent hasPrefix:@"zh"] == NO)
		argLang = @"eng";
		
    if ([ud integerForKey:kUDKeySVPLanguage] != 0)
    {
        if ([argLang compare:@"eng"] == NSOrderedSame)
            argLang = @"chn";
        else
            argLang = @"eng";
    }
  
    // call sscl [playerController.lastPlayedPath path]
	NSString *resPath = [[NSBundle mainBundle] resourcePath];
	
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: [resPath stringByAppendingPathComponent:@"plug-ins/sscl"] ];
	
	NSString* argPath = [NSString stringWithFormat:@"%@",[playerController.lastPlayedPath path]];

	// printf("%s \n", [argPath UTF8String]);
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"--pull", argPath, @"--lang", argLang, 
               @"--appid", [[[[NSBundle mainBundle] bundlePath] lastPathComponent] stringByDeletingPathExtension], nil];
	[task setArguments: arguments];
	
	NSPipe *pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	//[task setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	 
	[task launch];
	[task waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
		
	int status = [task terminationStatus];
	switch (status) {
		case 3:
			// require auth
            dispatch_async(dispatch_get_main_queue(), ^{
                [playerController setOSDMessage:kMPXStringSSCLReqAuth type:kOSDTypeSubSearch];
            });
			// TODO: message box?
			return [POOL release];
			break;
        default:
            break;
	}
	[task release];
	
	NSString *retString;
	retString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    MPLog(@"%s %lu %lu\n", [retString UTF8String], (unsigned long)[data length], (unsigned long)[retString length]);
  
	int resultCount = 0;
	NSArray *retLines = nil;
	if ([retString length] > 0)
	{
        retLines = [retString componentsSeparatedByCharactersInSet:
										     [NSCharacterSet newlineCharacterSet]];
        resultCount = [retLines count];
	}
	
  switch (resultCount) {
		case 0:
          dispatch_async(dispatch_get_main_queue(), ^{
			[playerController setOSDMessage:kMPXStringSSCLZeroMatched type:kOSDTypeSubSearch];
          });
			break;
		default:
		  {
				int acctureCount = 0;
				if (retLines)
				{
					NSArray* reversedLines = [[retLines reverseObjectEnumerator] allObjects];
					for (NSString* subPath in reversedLines)
					{
						// printf("%s \n", [subPath UTF8String]);
						if (subPath && ([subPath length] > 0))
						{
							if ([playerController loadSubFile:subPath])acctureCount++;
						}
					}
				}
              dispatch_async(dispatch_get_main_queue(), ^{
				if (acctureCount == 0)
					[playerController setOSDMessage:kMPXStringSSCLZeroMatched type:kOSDTypeSubSearch];
				else
					[playerController setOSDMessage:[NSString stringWithFormat:
                                                        kMPXStringSSCLGotResults, acctureCount] type:kOSDTypeSubSearch];
              });
		  }	
			break;
	}
	[POOL release];
}

+(void)pushSubtitle:(PlayerController*)playerController {
  
  NSAutoreleasePool* POOL = [[NSAutoreleasePool alloc] init];	
	
  if (![playerController.lastPlayedPath isFileURL])
		return [POOL release];
	
  NSString *subPath = [playerController getCurrentSubtitlePath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (!subPath || [fileManager fileExistsAtPath:subPath] == NO)
		return [POOL release];
  
	// call sscl [playerController.lastPlayedPath path]
	NSString *resPath = [[NSBundle mainBundle] resourcePath];
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: [resPath stringByAppendingPathComponent:@"plug-ins/sscl"] ];
	
	NSString* argPath = [NSString stringWithFormat:@"%@",[playerController.lastPlayedPath path]];
  
	MPLog(@"%s %s\n", [argPath UTF8String], [subPath UTF8String]);
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"--subtitle-file", subPath, @"--push", argPath, nil];
	[task setArguments: arguments];
	
	NSPipe *pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	//[task setStandardError: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	[task waitUntilExit];
	
	NSData *data;
	data = [file readDataToEndOfFile];
  
	int status = [task terminationStatus];
	[task release];
	
	NSString *retString;
	retString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
  MPLog(@"push Sub %d %s %lu %lu\n", status, [retString UTF8String], (unsigned long)[data length], (unsigned long)[retString length]);
  
	[POOL release];
}

+(CFDataRef) genAppstoreGuid
{
  kern_return_t             kernResult;
  mach_port_t               master_port;
  CFMutableDictionaryRef    matchingDict;
  io_iterator_t             iterator;
  io_object_t               service;
  CFDataRef                 macAddress = nil;
  
  kernResult = IOMasterPort(MACH_PORT_NULL, &master_port);
  if (kernResult != KERN_SUCCESS) {
    MPLog(@"IOMasterPort returned %d\n", kernResult);
    return nil;
  }
  
  matchingDict = IOBSDNameMatching(master_port, 0, "en0");
  if (!matchingDict) {
    MPLog(@"IOBSDNameMatching returned empty dictionary\n");
    return nil;
  }
  
  kernResult = IOServiceGetMatchingServices(master_port, matchingDict, &iterator);
  if (kernResult != KERN_SUCCESS) {
    MPLog(@"IOServiceGetMatchingServices returned %d\n", kernResult);
    return nil;
  }
  
  while((service = IOIteratorNext(iterator)) != 0) {
    io_object_t parentService;
    kernResult = IORegistryEntryGetParentEntry(service, kIOServicePlane, &parentService);
    if (kernResult == KERN_SUCCESS) {
      if (macAddress) CFRelease(macAddress);
      macAddress = (CFDataRef) IORegistryEntryCreateCFProperty(parentService,
                                                               CFSTR("IOMACAddress"), kCFAllocatorDefault, 0);
      IOObjectRelease(parentService);
    } else
      MPLog(@"IORegistryEntryGetParentEntry returned %d\n", kernResult);
                                               
    IOObjectRelease(iterator);
    IOObjectRelease(service);
  }
  return macAddress;
}

+(void)authAppstore {
  
  NSAutoreleasePool* POOL = [[NSAutoreleasePool alloc] init];	
  
  int nextTry = [[NSUserDefaults standardUserDefaults] integerForKey:kUDKeyNextSVPauthTime];
	int timestampNow = time(NULL);
  if (nextTry > timestampNow)
    return [POOL release];
    
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *receiptPath = [bundlePath stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:receiptPath] == NO)
    return [POOL release];
  
  NSString* resPath = [[NSBundle mainBundle] resourcePath];
  NSString* ssclPath = [resPath stringByAppendingPathComponent:@"plug-ins/sscl"];
  if ([fileManager fileExistsAtPath:ssclPath] == NO)
    return [POOL release];
  
  NSTask *task;
  task = [[NSTask alloc] init];
  [task setLaunchPath:ssclPath];
  NSArray *arguments;
  arguments = [NSArray arrayWithObjects: @"--uuid", nil];
  [task setArguments: arguments];	
  NSPipe *pipe = [NSPipe pipe];
  [task setStandardOutput: pipe];	
  NSFileHandle *file;
  file = [pipe fileHandleForReading];	
  [task launch];
  [task waitUntilExit];	
  NSData *data;
  data = [file readDataToEndOfFile];  
  [task release];
  NSString *splayer_uuid = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

  NSString *filename = @"receipt";
  NSString *boundary = @"----FOO";

  
  NSURL *url = [NSURL URLWithString:@"https://www.shooter.cn/api/v2/auth.php"];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
  [req setHTTPMethod:@"POST"];
  [req setValue:@"SPlayer 19780218 Mac OSX App" forHTTPHeaderField:@"User-Agent"];
    
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
  [req setValue:contentType forHTTPHeaderField:@"Content-type"];
  
  NSData *receiptData = [NSData dataWithContentsOfFile:receiptPath options:0 error:nil];
  CFDataRef appstoreGuidRef = [self genAppstoreGuid];
  NSData *appstoreGuid = [NSData dataWithBytes:CFDataGetBytePtr(appstoreGuidRef) length:CFDataGetLength(appstoreGuidRef)];

  //adding the body:
  NSMutableData *postBody = [NSMutableData data];
  [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:[@"Content-Disposition: form-data; name= \"splayer_uuid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:[splayer_uuid dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"receipt_file\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:[@"Content-Type: binary/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:receiptData];
  [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:[@"Content-Disposition: form-data; name= \"appstore_guid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [postBody appendData:appstoreGuid];
  [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [req setHTTPBody:postBody];
  
  [[NSURLConnection alloc] initWithRequest:req delegate:self];

  //get response
  NSHTTPURLResponse* urlResponse = nil;  
  NSError *error = [[NSError alloc] init];  
  NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&urlResponse error:&error];  
  NSString *resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
  
  MPLog(@"Auth response: %d %d %d %s %d %d %d", nextTry, timestampNow, [urlResponse statusCode], [resultString UTF8String], 
        [responseData length], [resultString length], [error code]);
  if ([urlResponse statusCode] == 200)
  {
    if([resultString  isEqual: @"OK"])
    {
      //authed
      nextTry = timestampNow + 3600*24*30;
    }
    else if([resultString rangeOfString:@"FAIL"].location == NSNotFound)
    {
      // tech error
      nextTry = timestampNow + 3600*24;
    } 
    else 
    {
      // not authed. try this next month 
      nextTry = timestampNow + 3600*24*30;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:((unsigned int)nextTry) forKey:kUDKeyNextSVPauthTime];
  }
  else {
    // tech error
    // try this next day
    nextTry = timestampNow + 3600*24;
    [[NSUserDefaults standardUserDefaults] setInteger:((unsigned int)nextTry) forKey:kUDKeyNextSVPauthTime];
  }

  [POOL release];
}
@end
