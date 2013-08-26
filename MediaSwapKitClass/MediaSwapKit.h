//
//  MediaSwapKit.h
//  Test-Receiver
//
//  Created by Jeff Bargmann on 8/24/13.
//  Copyright (c) 2013 PhotoSocial LLC. MIT License.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^MediaReceivedBlock)(UIImage *image, NSDictionary *metadata, NSString *uti, NSString *senderName, NSString *senderReplyUrl);


#define kMediaSwapKit_ProtocolVersion   (@1)
#define kMediaSwapKit_SenderName ((NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey])
#define kMediaSwapKit_DefaultReplyUrl (MediaSwapKit.defaultIncomingUrlScheme)


@interface MediaSwapKit : NSObject

//Sending
+ (bool) sendAsset: (ALAsset*) asset toUrl: (NSURL*) url withReplyUrl: (NSURL*) ReplyUrl;
+ (bool) sendImage: (UIImage*) image withMetadata: (NSDictionary*) metadata withUTI: (NSString*) uti toUrl: (NSURL*) url withReplyUrl: (NSURL*) ReplyUrl;
+ (bool) sendImageAsReply: (UIImage*) image;
+ (NSURL*) defaultIncomingUrlScheme;

//Receiving
+ (bool) handleUrlReceivedWithHandler: (MediaReceivedBlock) handler;

//Properties
+ (UIImage*) lastReceivedImage;
+ (NSString*) lastReceivedImageUTI;
+ (NSDictionary*) lastReceivedImageMetadata;
+ (NSString*) lastSenderName;
+ (NSURL*) lastSenderReplyUrl;
+ (bool) senderExpectingResponse;
+ (void) reset;

@end
