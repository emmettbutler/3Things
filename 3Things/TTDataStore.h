//
//  ShareDayStore.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TTDataStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

- (NSManagedObject *)createItem:(NSString *)entityType;
- (void)saveChanges;
- (NSDate *)getDateOnly;
- (NSArray *)allItems:(NSString *)entityType withSort:(NSString *)_sort andPredicate:(NSPredicate *)predicate;

@end
