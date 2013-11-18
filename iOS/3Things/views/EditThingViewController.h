//
//  EditThingViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "TTShareDay.h"
#import "PhotoPromptViewController.h"
#import "TTNetManager.h"

@interface EditThingViewController : UIViewController <UITextViewDelegate, PhotoPromptViewControllerDelegate, TTNetManagerDelegate>
{
    CGRect screenFrame, textFieldFrame;
    UIImageView *picView;
}

- (id) initWithThingIndex:(NSNumber *)thingIndex andShares:(TTShareDay *)shares;
- (NSString *)getNumberWord;
- (Thing *)saveThingWithIndex:(NSNumber *)index;
- (void) registerCurrentThing;

@property (nonatomic) UITextView *textField;
@property (nonatomic) TTShareDay *shares;
@property (nonatomic) NSNumber *thingIndex;
@property (nonatomic) NSString *thingText;
@property (nonatomic) NSString *thingLocalImageURL;
@property (nonatomic) BOOL firstEdit;
@property (nonatomic) BOOL photoPromptIsHidden;

@end
