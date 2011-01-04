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

	NSAutoreleasePool* POOL = [[NSAutoreleasePool alloc] init];	
	// send osd
	if (![playerController.lastPlayedPath isFileURL])
		return [POOL release];
	
	[playerController setOSDMessage:kMPXStringSSCLFetching];
	
	// call sscl [playerController.lastPlayedPath path]
	NSString *resPath = [[NSBundle mainBundle] resourcePath];
	
	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: [resPath stringByAppendingPathComponent:@"binaries/x86_64/sscl"] ];
	
	NSString* argPath = [NSString stringWithFormat:@"%@",[playerController.lastPlayedPath path]];

	// printf("%s \n", [argPath UTF8String]);
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"--pull", argPath, nil];
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

@end
