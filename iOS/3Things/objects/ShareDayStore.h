//
//  ShareDayStore.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ShareDay.h"
#import "TTDataStore.h"

@interface ShareDayStore : TTDataStore
{
}

- (ShareDay *)createShareDay;
- (NSArray *)allItemsForUser:(User *)user;
- (NSArray *)allItemsForUser:(User *)user andDay:(NSString *)day;
- (ShareDay *)getToday;

@end
