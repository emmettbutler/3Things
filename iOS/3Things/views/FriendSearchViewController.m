//
//  FriendSearchViewController.m
//  3Things
//
//  Created by Emmett Butler on 11/13/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "TTNetManager.h"

@interface FriendSearchViewController ()

@end

@implementation FriendSearchViewController
@synthesize searchDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, 110, screenFrame.size.width, screenFrame.size.height);
    self.frame = popupFrame;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    TTLog(@"Search dismiss activated");
    [searchDelegate dismissSearchWasTouched];
}

@end
