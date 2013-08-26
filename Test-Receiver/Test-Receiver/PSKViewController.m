//
//  PSKViewController.m
//  Test-Receiver
//
//  Created by Jeff Bargmann on 8/24/13.
//  Copyright (c) 2013 PhotoSocial LLC. MIT License.
//

#import "PSKViewController.h"
#import "MediaSwapKit.h"

@interface PSKViewController ()

@end

@implementation PSKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)sendButtonHit:(id)sender {
    //Verify we have an image to send
    if(!MediaSwapKit.lastReceivedImage || !self.photoImageView.image)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No image loaded" message:@"Load image from sender to continue" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

    //Send image
    [MediaSwapKit sendImageAsReply:self.photoImageView.image];
    
    //Reset
    [MediaSwapKit reset];
    self.photoImageView.image = nil;
}
+(UIImage*) drawText:(NSString*) text inImage:(UIImage*) image atPoint:(CGPoint) point
{
    //Crude method for adding text to image
    UIFont *font = [UIFont boldSystemFontOfSize:100];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    rect.size = [text sizeWithFont:font];
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] set];
    UIRectFill(rect);
    [[UIColor whiteColor] setFill];
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void) loadIncomingImageFromMediaSwapKit {
    //Sanity
    if(!MediaSwapKit.lastReceivedImage)
        return;
    
    //Load image
    self.photoImageView.image = MediaSwapKit.lastReceivedImage;
    
    //Modify image
    self.photoImageView.image = [PSKViewController drawText:[[NSDate date] description]
                                                    inImage:MediaSwapKit.lastReceivedImage atPoint:CGPointMake(0, 0)];
}
@end
