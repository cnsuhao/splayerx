#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
@import AppKit;
#import <SPQuickLookgl.h>

NSString* MPlayerPath(){
    NSString* mpath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"org.splayer.splayerx"];
    if (mpath == nil)
        return mpath;
    
    mpath = [mpath stringByAppendingPathComponent:@"Contents/Resources/binaries/x86_64/mplayer-mt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:mpath])
        return mpath;
    
    return nil;
}

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    NSString* mpath = MPlayerPath();
    NSLog(@"[SPQL] mplayer-mt: %@",  mpath);
    
    NSString *globallyUniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    globallyUniqueString = [[globallyUniqueString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSString *tmpdir = [NSTemporaryDirectory() stringByAppendingPathComponent:globallyUniqueString];
    NSString *tmpfile = [tmpdir stringByAppendingPathComponent:@"00000001.png"];
    NSString* moviepath = [(__bridge NSURL *)url path];
    
    // TODO: predict video length
    NSArray *args = [NSArray arrayWithObjects:moviepath, @"-ss", @"5", @"-frames", @"1", @"-nosound", @"-vo",
                     [NSString stringWithFormat:@"png:z=0:outdir=%@", tmpdir], nil];
    [[NSTask launchedTaskWithLaunchPath:mpath arguments:args] waitUntilExit];
    
    CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:tmpfile]);
    CGImageRef thumb = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    
    if (thumb == nil)
        return noErr;

    size_t thumb_width = CGImageGetWidth(thumb);
    size_t thumb_height = CGImageGetHeight(thumb);
    
    // Preview will be drawn in a vectorized context
    CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, CGSizeMake(thumb_width, thumb_height), false, NULL);
    if(cgContext) {
        CGContextDrawImage(cgContext, CGRectMake(0, 0, thumb_width, thumb_height), thumb);
        
        QLThumbnailRequestFlushContext(thumbnail, cgContext);
        CFRelease(cgContext);
        CGImageRelease(thumb);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:tmpfile error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tmpdir error:nil];
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
