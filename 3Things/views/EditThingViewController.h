//
//  EditThingViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTShareDay.h"

@interface EditThingViewController : UIViewController <UITextViewDelegate>

- (id) initWithThingIndex:(NSNumber *)thingIndex andShares:(TTShareDay *)shares;
- (NSString *)getNumberWord;

@property (nonatomic) TTShareDay *shares;
@property (nonatomic) NSNumber *thingIndex;
@property (nonatomic) NSString *thingText;
@property (nonatomic) BOOL firstEdit;

@end
