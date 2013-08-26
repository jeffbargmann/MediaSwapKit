//
//  PSKViewController.h
//  Test-Receiver
//
//  Created by Jeff Bargmann on 8/24/13.
//  Copyright (c) 2013 PhotoSocial LLC. MIT License.
//

#import <UIKit/UIKit.h>

@interface PSKViewController : UIViewController

- (void) loadIncomingImageFromMediaSwapKit;
- (IBAction)sendButtonHit:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;

@end
