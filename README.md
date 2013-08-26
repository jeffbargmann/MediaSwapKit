MediaSwapKit
============

Simple framework for sharing images between applications using UIPasteboard


Sending images from an ALAsset
--------------------

Sending with this method will preserve all image metadata. Metadata is included as NSDictionary along-side the UIImage.

```
NSString *targetUrl = [NSURL URLWithString:@"mediaswapkit-editor://editimage"];
[MediaSwapKit sendAsset:asset toUrl:targetUrl withReplyUrl:kMediaSwapKit_DefaultReplyUrl];
```

Sending images from a UIImage
--------------------

```
[MediaSwapKit sendImage:image withMetadata:metadata withUTI:imageUTI toUrl:targetUrl withReplyUrl:returnUrl];
```




Receiving images
--------------------

1) Add URL Scheme to your application. (See http://www.idev101.com/code/Objective-C/custom_url_schemes.html)

2) Handle incoming images in your UIApplicationDelegate

```
#import "MediaSwapKit.h"

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
        sourceApplication:(NSString *)sourceApplication  annotation:(id)annotation {

  //Detect and handle incoming images
  if([MediaSwapKit handleUrlReceivedWithHandler:^(UIImage *image, NSDictionary *metadata, NSString *uti, NSString *senderName, NSString *senderReplyUrl) {
    //...Your code here
  }])
  { return YES; }
  
  return NO;
}
```

3) Access image data from anywhere with static methods

```
self.photoViewer.image = [MediaSwapKit lastReceivedImage];
```

4) Send image in return (optional)

```
//Send image to caller
[MediaSwapKit sendImageAsReply:editingResultImage];

//The above line is equivalent to:
[MediaSwapKit sendImage:editingResultImage withMetadata:MediaSwapKit.lastReceivedImageMetadata withUTI:MediaSwapKit.lastReceivedImageUTI toUrl:MediaSwapKit.lastSenderReplyUrl withReplyUrl:nil];
```

