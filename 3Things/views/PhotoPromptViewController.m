//
//  PhotoPromptViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "PhotoPromptViewController.h"
#import "EditThingViewController.h"

@interface PhotoPromptViewController ()

@end

@implementation PhotoPromptViewController
@synthesize promptDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"Photo prompt loaded");
    
    self.view.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, screenFrame.size.height-180, screenFrame.size.width, 200);
    
    UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [takeButton addTarget:self
                   action:@selector(takeWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [takeButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    takeButton.frame = CGRectMake(0, 0, popupFrame.size.width, 60);
    [self.view addSubview:takeButton];
    
    UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chooseButton addTarget:self
                   action:@selector(chooseWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [chooseButton setTitle:@"Choose from Photos" forState:UIControlStateNormal];
    chooseButton.frame = CGRectMake(0, 60, popupFrame.size.width, 60);
    [self.view addSubview:chooseButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton addTarget:self
                     action:@selector(cancelWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(0, 140, popupFrame.size.width, 60);
    [self.view addSubview:cancelButton];
}

- (void)takeWasTouched
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)chooseWasTouched
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
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
    [self.promptDelegate photoWasSelected:chosenImage];
    [self cancelWasTouched];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
