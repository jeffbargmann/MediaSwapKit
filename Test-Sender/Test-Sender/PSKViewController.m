//
//  PSKViewController.m
//  Test-Sender
//
//  Created by Jeff Bargmann on 8/24/13.
//  Copyright (c) 2013 PhotoSocial LLC. MIT License.
//

#import "PSKViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MediaSwapKit.h"

@interface PSKViewController ()

@end

@implementation PSKViewController

static ALAssetsLibrary *_library;
static ALAsset *_asset;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load most recent image from user's asset library
    [self loadImage];
}
- (void) loadImage
{
    //Only once
    if(_asset)
        return;
    
    //Load most recent image from user's asset library
    _library = [[ALAssetsLibrary alloc] init];
    [_library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if(asset)
            {
                //Display image, save asset for later use
                _asset = asset;
                self.photoImageView.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                
                //Stop search
                (*stop) = true;
            }
        }];
    } failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not load image" message:@"Please grant access to your photo collection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)sendButtonHit:(id)sender {
    
    //Notify if no image
    if(!_asset)
        [self loadImage];
    if(!_asset)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No image found" message:@"Please grant access to your photo collection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    //Perform send
    [MediaSwapKit sendAsset:_asset toUrl:[NSURL URLWithString:@"mediaswapkit-editor://editimage"] withReturnUrl:kMediaSwapKit_DefaultSenderUrl];
}

- (void) saveIncomingImageFromMediaSwapKit {
    //Sanity
    if(!MediaSwapKit.lastReceivedImage)
        return;
    
    //Write image to library
    [_library writeImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(MediaSwapKit.lastReceivedImage, 0.9) metadata:MediaSwapKit.lastReceivedImageMetadata completionBlock:^(NSURL *assetURL, NSError *error) {
        //Retrieve asset for next round
        [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            
            //Display image, save asset for later use
            _asset = asset;
            self.photoImageView.image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
         
            //Notify
            UIAlertView *alert = [[UIAlertView alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setTitle:@"Asset written to library"];
            [alert setMessage:assetURL.absoluteString];
            [alert show];
            
        } failureBlock:nil];
    }];
}
@end
