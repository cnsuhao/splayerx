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

@implementation ssclThread
+(void)pullSubtitle:(PlayerController*)playerController 
{

  //[self authAppstore];
  
	NSAutoreleasePool* POOL = [[NSAutoreleasePool alloc] init];	
	// send osd
	if (![playerController.lastPlayedPath isFileURL])
		return [POOL release];
	
	[playerController setOSDMessage:kMPXStringSSCLFetching];
	
	NSString* argLang = [NSString stringWithString:@"chn"];
	NSString* langCurrent = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
	if ([langCurrent hasPrefix:@"zh"] == NO)
		argLang = [NSString stringWithString:@"eng"];
		
		// call sscl [playerController.lastPlayedPath path]
	NSString *resPath = [[NSBundle mainBundle] resourcePath];
	
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: [resPath stringByAppendingPathComponent:@"binaries/x86_64/sscl"] ];
	
	NSString* argPath = [NSString stringWithFormat:@"%@",[playerController.lastPlayedPath path]];

	// printf("%s \n", [argPath UTF8String]);
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"--pull", argPath, @"--lang", argLang, nil];
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
			[playerController setOSDMessage:kMPXStringSSCLReqAuth];
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
			[playerController setOSDMessage:kMPXStringSSCLZeroMatched];
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
						if (subPath && [subPath length] > 0)
						{
							[playerController loadSubFile:subPath];
							acctureCount++;
						}
					}
				}
				if (acctureCount == 0)
					[playerController setOSDMessage:kMPXStringSSCLZeroMatched];
				else
					[playerController setOSDMessage:[NSString stringWithFormat:
																					 kMPXStringSSCLGotResults, acctureCount]];
		  }	
			break;
	}
	[POOL release];
}

+(void)pushSubtitle:(PlayerController*)playerController {

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
	
  NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *receiptPath = [bundlePath stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:receiptPath] == NO)
    return [POOL release];
  
  
	NSTask *task;
	task = [[NSTask alloc] init];
  NSString* resPath = [[NSBundle mainBundle] resourcePath];
	[task setLaunchPath: [resPath stringByAppendingPathComponent:@"binaries/x86_64/sscl"] ];
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
  
  MPLog(@"Auth response: %d %s %d %d %d", [urlResponse statusCode], [resultString UTF8String], 
        [responseData length], [resultString length], [error code]);
  if ([urlResponse statusCode] == 200)
  {
    // not trying anymore
    if(resultString == @"OK")
    {
      //authed
    }
  }
  else {
    // try this next time
  }

  [POOL release];
}
@end
