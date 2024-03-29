//
//  TTShareDay.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareDay.h"
#import "User.h"

@interface TTShareDay : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSDate *time;
@property (nonatomic) User *user;
@property (nonatomic) NSString *_id;
@property (nonatomic) NSMutableArray *commentCount;
@property (nonatomic) NSMutableArray *theThings;

+ (TTShareDay *)shareDayWithShareObject:(ShareDay *)shares;
- (id) initWithSharesDictionary:(NSDictionary *)shares;

@end
