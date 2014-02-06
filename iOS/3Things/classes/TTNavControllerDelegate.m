//
//  TTNavControllerDelegate.m
//  3Things
//
//  Created by Emmett Butler on 2/5/14.
//  Copyright (c) 2014 Emmett Butler. All rights reserved.
//

#import "TTNavControllerDelegate.h"
#import "TTNetManager.h"

@implementation TTNavControllerDelegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [TTNetManager sharedInstance].netDelegate = nil;
}

@end
