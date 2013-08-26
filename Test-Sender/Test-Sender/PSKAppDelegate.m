//
//  PSKAppDelegate.m
//  Test-Sender
//
//  Created by Jeff Bargmann on 8/24/13.
//  Copyright (c) 2013 PhotoSocial LLC. MIT License.
//

#import "PSKAppDelegate.h"
#import "PSKViewController.h"
#import "MediaSwapKit.h"

@implementation PSKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[PSKViewController alloc] initWithNibName:@"PSKViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application
{
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}
- (void)applicationWillTerminate:(UIApplication *)application
{
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //Detect and handle incoming images
    if([MediaSwapKit handleUrlReceivedWithHandler:^(UIImage *image, NSDictionary *metadata, NSString *uti, NSString *senderName, NSString *senderReturnUrl) {
        
        //Display debug data
        NSMutableString *debugOutput = [NSMutableString stringWithCapacity:2000];
        [debugOutput appendFormat:@"Image: %dx%d", (int)image.size.width, (int)image.size.height];
        [debugOutput appendFormat:@"\nImageUTI: %@", uti];
        [debugOutput appendFormat:@"\nSender: %@", senderName];
        [debugOutput appendFormat:@"\nReturnURL: %@", senderReturnUrl];
        [debugOutput appendFormat:@"\nMetadata:\n%@", metadata];
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessage:debugOutput];
        [alert show];
        
        //Processing incoming image
        [((PSKViewController*)self.viewController) saveIncomingImageFromMediaSwapKit];
    }])
    {
        return YES;
    }
    
    return NO;
}

@end
