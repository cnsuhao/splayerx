//
//  ssclThread.m
//  MPlayerX
//
//  Created by tomasen on 11-1-2.
//  Copyright 2011 SPlayerX. All rights reserved.
//

#import "ssclThread.h"
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
	
	NSString* argPath = [NSString stringWithFormat:@"\"%@\"",[playerController.lastPlayedPath path]];

	NSArray *arguments;
	arguments = [NSArray arrayWithObjects: @"--pull", argPath, nil];
	[task setArguments: arguments];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[task launch];
	[task waitUntilExit];
	
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
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *retString;
	retString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
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
			return [POOL release];
			break;
		default:
			[playerController setOSDMessage:[NSString stringWithFormat:
																			 kMPXStringSSCLGotResults, resultCount]];
			if (retLines)
  			for (NSString* subPath in retLines)
	  			if (subPath && [subPath length] > 0)
  	  			[playerController loadSubFile:subPath];

			break;
	}
	[POOL release];
}

+(void)pushSubtitle:(PlayerController*)playerController {

}

@end
