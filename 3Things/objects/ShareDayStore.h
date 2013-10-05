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

@interface ShareDayStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

- (ShareDay *)createShareDay;
- (void)saveChanges;
- (NSArray *)allItems;

@end
