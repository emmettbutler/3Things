//
//  TTSharesAccessor.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTShareDay.h"


@interface TTSharesAccessor : NSObject

- (TTShareDay *)getFriendSharesForDate:(NSDate *)date;
- (TTShareDay *)getFriendSharesForDate:(NSDate *)date andUserName:(NSString *)name;

@end
