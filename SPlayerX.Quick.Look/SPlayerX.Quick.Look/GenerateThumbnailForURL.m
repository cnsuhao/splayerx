#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
@import AppKit;

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
    CGContextRef cgContext = QLThumbnailRequestCreateContext(thumbnail, CGSizeMake(thumb_width, thumb_height), true, NULL);
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


OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
 Generate a preview for file
 
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
    // To complete your generator please implement the function GeneratePreviewForURL in GeneratePreviewForURL.c
    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    NSString* mpath = MPlayerPath();
    NSLog(@"[SPQL] mplayer-mt: %@",  mpath);
    
    NSString *globallyUniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    globallyUniqueString = [[globallyUniqueString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSString *tmpdir = [NSTemporaryDirectory() stringByAppendingPathComponent:globallyUniqueString];
    NSString *tmpfile = [tmpdir stringByAppendingPathComponent:@"00000001.png"];
    NSString* moviepath = [(__bridge NSURL *)url path];
    
    NSTask* task = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"-identify", moviepath, @"-ss", @"5", @"-frames", @"1", @"-ao", @"null", @"-vo",
                     [NSString stringWithFormat:@"png:z=0:outdir=%@", tmpdir], nil];
    [task setLaunchPath:mpath];
    [task setArguments:args];
    NSPipe * out = [NSPipe pipe];
    [task setStandardOutput:out];
    [task launch];
    [task waitUntilExit];
    
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    NSArray *array = [stringRead componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath:moviepath error: NULL];
    
    NSMutableString * mediaInfo = [NSMutableString string];
    
    float movieLength = -1;
    for(int i=0; i<[array count]; i++){
        NSString* line = array[i];
        
        if ([line hasPrefix:@"ID_LENGTH"] || [line hasPrefix:@"MPX_LENGTH"]){
            NSArray *items = [line componentsSeparatedByString:@"="];
            if ([items count] > 1) {
                NSString* length = items[1];
                movieLength = MAX(movieLength,[length floatValue]);
            }
        } else if ([line hasPrefix:@"VIDEO:"]){
        } else if ([line hasPrefix:@"AUDIO:"]){
        }else {
            continue;
        }
        
        [mediaInfo appendFormat:@"%@\n", line];
    }
    
    if (movieLength > 0){
        [mediaInfo appendFormat:@"LENGTH: %02li:%02li:%02li\n",
         lround(floor(movieLength / 3600.)) % 100,
         lround(floor(movieLength / 60.)) % 60,
         lround(floor(movieLength)) % 60];
    }
    
    [mediaInfo appendFormat:@"LAST MODIFIED TIME: %@\n", [[attrs fileModificationDate] descriptionWithLocale:[NSLocale systemLocale]]];
    
    if (NSClassFromString(@"NSByteCountFormatter") != nil) {
        [mediaInfo appendFormat:@"FILE SIZE: %@\n", [NSByteCountFormatter stringFromByteCount:[attrs fileSize]
                                                                                   countStyle:NSByteCountFormatterCountStyleFile]];
    } else {
        [mediaInfo appendFormat:@"FILE SIZE: %llu Bytes\n",[attrs fileSize]];
    }
    
    
    CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)[NSData dataWithContentsOfFile:tmpfile]);
    CGImageRef thumb = CGImageCreateWithPNGDataProvider(imgDataProvider, NULL, true, kCGRenderingIntentDefault);
    
    if (thumb == nil)
        return noErr;
    
    size_t thumb_width = CGImageGetWidth(thumb);
    size_t thumb_height = CGImageGetHeight(thumb);
    
    
    // Preview will be drawn in a vectorized context
    CGContextRef cgContext = QLPreviewRequestCreateContext(preview, CGSizeMake(thumb_width+60, thumb_height+180), true, NULL);
    if(cgContext) {
        CGContextSaveGState(cgContext);
        CGContextSetShadowWithColor(cgContext, CGSizeMake(1, -2), 5.0, [NSColor shadowColor].CGColor);
        CGContextDrawImage(cgContext, CGRectMake(30, 160, thumb_width, thumb_height), thumb);
        CGContextRestoreGState(cgContext);
        
        CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontApplicationFontType, 14, NULL);
        
        // Set the lineSpacing.
        CGFloat lineSpacing = (CTFontGetLeading(font) + 3) * 2;
        
        // Create the paragraph style settings.
        CTParagraphStyleSetting setting;
        
        setting.spec = kCTParagraphStyleSpecifierParagraphSpacing;
        setting.valueSize = sizeof(CGFloat);
        setting.value = &lineSpacing;
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(&setting, 1);
        
        CFStringRef textString = (__bridge CFStringRef)mediaInfo;
        
        CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), textString);
        CFRange stringRange = CFRangeMake(0, CFAttributedStringGetLength(attrString));
        
        CFAttributedStringSetAttribute(attrString, stringRange, kCTFontAttributeName, font);
        CFAttributedStringSetAttribute(attrString, stringRange, kCTForegroundColorAttributeName, [[NSColor darkGrayColor] CGColor]);
        CFAttributedStringSetAttribute(attrString, stringRange, kCTParagraphStyleAttributeName, paragraphStyle);
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect bounds = CGRectMake(30.0, 0, thumb_width, 130);
        CGPathAddRect(path, NULL, bounds);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        
        // Draw the specified frame in the given context.
        CTFrameDraw(frame, cgContext);
        
        CFRelease(attrString);
        CFRelease(font);
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
        
        QLPreviewRequestFlushContext(preview, cgContext);
        CFRelease(cgContext);
        CGImageRelease(thumb);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:tmpfile error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tmpdir error:nil];
    
    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}

