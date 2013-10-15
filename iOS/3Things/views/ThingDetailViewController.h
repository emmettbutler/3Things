//
//  ThingDetailViewController.h
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThingDetailViewController : UIViewController

@property (nonatomic) CGRect screenFrame;
@property (nonatomic) NSDictionary *thing;

- (id)initWithThing:(NSDictionary *)inThing;

@end
