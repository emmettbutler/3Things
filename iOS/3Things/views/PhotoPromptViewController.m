//
//  PhotoPromptViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTNetManager.h"
#import "PhotoPromptViewController.h"
#import "EditThingViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"

@interface PhotoPromptViewController ()

@end

@implementation PhotoPromptViewController
@synthesize promptDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	TTLog(@"Photo prompt loaded");
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, screenFrame.size.height-180, screenFrame.size.width, 200);
    
    UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takeButton addTarget:self
                   action:@selector(takeWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [takeButton setTitle:@"TAKE PHOTO" forState:UIControlStateNormal];
    takeButton.frame = CGRectMake(0, 0, popupFrame.size.width, 60);
    takeButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    [self.view addSubview:takeButton];
    [takeButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
    
    UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chooseButton addTarget:self
                   action:@selector(chooseWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [chooseButton setTitle:@"CHOOSE FROM PHOTOS" forState:UIControlStateNormal];
    chooseButton.frame = CGRectMake(0, 60, popupFrame.size.width, 60);
    chooseButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    [self.view addSubview:chooseButton];
    [chooseButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self
                     action:@selector(cancelWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [cancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(0, 140, popupFrame.size.width, 60);
    cancelButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    [self.view addSubview:cancelButton];
    [cancelButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
}

- (void)takeWasTouched
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)chooseWasTouched
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)cancelWasTouched
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    if (info[UIImagePickerControllerReferenceURL] == nil) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        // Request to save the image to camera roll
        [library writeImageToSavedPhotosAlbum:[chosenImage CGImage] orientation:(ALAssetOrientation)[chosenImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                TTLog(@"error saving image");
            } else {
                [self.promptDelegate photoWasSaved:assetURL];
            }  
        }];
    } else {
        [self.promptDelegate photoWasSaved:info[UIImagePickerControllerReferenceURL]];
    }
    
    [self.promptDelegate photoWasSelected:chosenImage];
    [self cancelWasTouched];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
