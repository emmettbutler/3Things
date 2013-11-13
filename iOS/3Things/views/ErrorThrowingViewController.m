//
//  ErrorThrowingViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/12/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ErrorThrowingViewController.h"

@interface ErrorThrowingViewController ()

@end

@implementation ErrorThrowingViewController

-(id) init {
    if (self = [super init]){
        self.errViewIsShown = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) dismissWasTouched {
    self.errViewIsShown = NO;
}

@end
