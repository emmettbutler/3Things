//
//  TTShareDay.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTShareDay : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *userName;
@property (nonatomic) NSString *userFullName;
@property (nonatomic) NSMutableArray *theThings;

@end
