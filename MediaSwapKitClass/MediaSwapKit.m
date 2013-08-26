//
//  MediaSwapKit.m
//  Test-Receiver
//
//  Created by Jeff Bargmann on 8/24/13.
//  Copyright (c) 2013 PhotoSocial LLC. MIT License.
//

#import "MediaSwapKit.h"

#define kUTTypeJPEG @"public.jpeg"

@implementation MediaSwapKit

//Sending
+ (bool) sendAsset: (ALAsset*) asset toUrl: (NSURL*) url withReturnUrl: (NSURL*) returnUrl
{
    //Sanity
    if(!asset || !url.absoluteString.length)
        return false;
    
    //Get photo image, type & metadata
    UIImageOrientation orientation = UIImageOrientationUp;  //raw image must be manually rotated
    NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
    if (orientationValue != nil)
        orientation = [orientationValue intValue];
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1 orientation:orientation];
    NSDictionary *metadata = asset.defaultRepresentation.metadata;
    NSString *uti = asset.defaultRepresentation.UTI;
    if(!image)
        return false;
 
    //Send
    return [self sendImage:image withMetadata:metadata withUTI:uti toUrl:url withReturnUrl:returnUrl];
}
+ (bool) sendImageAsReply: (UIImage*) image {
    if(!self.senderExpectingResponse)
        return false;
    return [MediaSwapKit sendImage:image withMetadata:MediaSwapKit.lastReceivedImageMetadata withUTI:MediaSwapKit.lastReceivedImageUTI toUrl:MediaSwapKit.lastSenderReturnUrl withReturnUrl:nil];
}
+ (bool) sendImage: (UIImage*) image withMetadata: (NSDictionary*) metadata withUTI: (NSString*) uti toUrl: (NSURL*) url withReturnUrl: (NSURL*) returnUrl
{
    //Sanity
    if(!image || !url.absoluteString.length)
        return false;
    
    //Validate URL
    if(![[UIApplication sharedApplication] canOpenURL:url])
        return false;
    
    //Validate UTI. Known pasteboard UTI is required. Enforce JPEG if missing or invalid.
    bool validUTI = false;
    for(NSString *type in UIPasteboardTypeListImage)
    {
        if(![type isEqualToString:uti])
            continue;
        validUTI = true;
        break;
    }
    if(!validUTI)
        uti = (NSString*) kUTTypeJPEG;
       
    //Copy image to lock in orientation
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Clear orientation data from metadata
    NSMutableDictionary *metadataEdited = metadata.mutableCopy;
    [metadataEdited removeObjectForKey:@"Orientation"];
    if([metadataEdited objectForKey:@"{TIFF}"])
    {
        [metadataEdited setObject:[[metadataEdited objectForKey:@"{TIFF}"] mutableCopy] forKey:@"{TIFF}"];
        [[metadataEdited objectForKey:@"{TIFF}"] removeObjectForKey:@"Orientation"];
    }
    metadata = metadataEdited;
    
    //Add image to pasteboard
    NSMutableArray *pasteboardContents = [NSMutableArray array];
    [pasteboardContents addObject:@{uti: image}];
    
    //Add metadata to pasteboard
    if(metadata)
        [pasteboardContents addObject:@{@"metadata": [NSKeyedArchiver archivedDataWithRootObject:metadata]}];
    
    //Add sender details to pasteboard
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:kMediaSwapKit_ProtocolVersion forKey:@"protocolVersion"];
    if(kMediaSwapKit_SenderName.length)
        [userInfo setObject:kMediaSwapKit_SenderName forKey:@"senderName"];
    if(returnUrl.absoluteString.length)
        [userInfo setObject:returnUrl.absoluteString forKey:@"senderReturnUrl"];
    [pasteboardContents addObject:@{@"mediaSwapKitUserInfo": [NSKeyedArchiver archivedDataWithRootObject:userInfo]}];
    
    //Save pasteboard contents
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.items = pasteboardContents;
    
    //Open other application
    [[UIApplication sharedApplication] openURL:url];
    return true;
}

//Receiving
+ (bool) handleUrlReceivedWithHandler: (MediaReceivedBlock) handler
{
    //Sanity
    if(!handler)
        return false;
    
    
    //Check for MediaSwap userinfo.
    //Manually check pasteboard items...valueForPasteboardType not seeming to find it.
    NSMutableDictionary *userInfo;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    for(NSDictionary *pasteboardItem in pasteboard.items)
    {
        if([pasteboardItem objectForKey:@"mediaSwapKitUserInfo"])
            userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboardItem objectForKey:@"mediaSwapKitUserInfo"]];
    }
    if(!userInfo)
        return false;
    
    
    //Read image off pasteboard
    UIImage *image;
    NSString *uti;
    for(NSString *type in UIPasteboardTypeListImage)
    {
        image = [pasteboard valueForPasteboardType:type];
        uti = type;
        if(image)
            break;
    }
    
    
    //Read metadata
    NSDictionary *metadata;
    for(NSDictionary *pasteboardItem in pasteboard.items)
    {
        if([pasteboardItem objectForKey:@"metadata"])
            metadata = [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboardItem objectForKey:@"metadata"]];
    }
    
    
    //Read sender info
    NSString *senderName = [userInfo valueForKey:@"senderName"];
    NSString *senderReturnUrl = [userInfo valueForKey:@"senderReturnUrl"];
    if(!image)
        return false;
    
    //Save to global variables for future reference
    _lastReceivedImage = image;
    _lastReceivedImageMetadata = metadata;
    _lastReceivedImageUTI = uti;
    _lastSenderName = senderName;
    _lastSenderReturnUrl = (senderReturnUrl.length?[NSURL URLWithString:senderReturnUrl]:nil);
    
    //Clear the pasteboard
    pasteboard.string = @" ";
    
    //Pass to handler
    handler(image, metadata, uti, senderName, senderReturnUrl);
    return true;
}

//Utility fn for finding URL Scheme for the calling app
+ (NSURL*) defaultIncomingUrlScheme
{
    //Locate first scheme from main bundle's url scheme list
    NSURL *result;
    for(NSDictionary *url in [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"])
    {
        NSArray *schemes = [url objectForKey:@"CFBundleURLSchemes"];
        if(!schemes.count)
            continue;
        result = [NSURL URLWithString:[((NSString*)[schemes objectAtIndex:0]) stringByAppendingString:@"://sendimage"]];
        break;
    }
    return result;
}

//Properties for easy global access
static UIImage *_lastReceivedImage;
static NSString *_lastReceivedImageUTI;
static NSDictionary *_lastReceivedImageMetadata;
static NSString *_lastSenderName;
static NSURL *_lastSenderReturnUrl;
+ (UIImage*) lastReceivedImage { return _lastReceivedImage; }
+ (NSString*) lastReceivedImageUTI { return _lastReceivedImageUTI; }
+ (NSDictionary*) lastReceivedImageMetadata { return _lastReceivedImageMetadata; }
+ (NSString*) lastSenderName { return _lastSenderName; }
+ (NSURL*) lastSenderReturnUrl { return _lastSenderReturnUrl; }
+ (bool) senderExpectingResponse { return _lastSenderReturnUrl.absoluteString.length; }
+ (void) reset {
    _lastReceivedImage = nil;
    _lastReceivedImageUTI = nil;
    _lastReceivedImageMetadata = nil;
    _lastSenderName = nil;
    _lastSenderReturnUrl = nil;
}
@end
