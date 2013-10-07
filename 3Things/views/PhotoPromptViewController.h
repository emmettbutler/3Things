//
//  PhotoPromptViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoPromptViewController;
@protocol PhotoPromptViewControllerDelegate <NSObject>
@optional
- (void) photoWasSelected:(UIImage *)selectedImage;
- (void) photoWasSaved:(NSURL *)savedPhotoURL;
@end

id <PhotoPromptViewControllerDelegate> promptDelegate;

@interface PhotoPromptViewController : UIViewController <UIImagePickerControllerDelegate>

@property (nonatomic, assign) id <PhotoPromptViewControllerDelegate> promptDelegate;

@end
