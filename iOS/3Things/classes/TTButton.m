//
//  TTButton.m
//  3Things
//
//  Created by Emmett Butler on 11/19/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTButton.h"

@implementation TTButton

- (CGRect)backgroundRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.size.width*.15, bounds.size.height*.15, bounds.size.width*.7, bounds.size.height*.7);
}

@end
