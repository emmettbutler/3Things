//
//  EditThingViewController.h
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditThingViewController : UIViewController <UITextViewDelegate>

- (id) initWithThingIndex:(NSNumber *)thingIndex;
- (NSString *)getNumberWord;

@property (nonatomic) NSNumber *thingIndex;

@end
