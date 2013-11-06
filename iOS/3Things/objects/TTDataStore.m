//
//  ShareDayStore.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTDataStore.h"
#import "AppDelegate.h"

@implementation TTDataStore

- (id)init
{
    self = [super init];
    
    if (self)
    {
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate]; //Get reference to App Delegate
        context = [appDelegate managedObjectContext]; //Save the pointer to the shared context
        model = [appDelegate managedObjectModel];
    }
    
    return self;
}

- (NSManagedObject *)createItem:(NSString *)entityType
{
    NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:entityType inManagedObjectContext:context];
    return newItem;
}

- (NSArray *)allItems:(NSString *)entityType withSort:(NSString *)_sort andPredicate:(NSPredicate *)predicate
{
    if (_sort == NULL) {
        _sort = @"id";
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [[model entitiesByName] objectForKey:entityType];
    [request setEntity:description];

    [request setPredicate:predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:_sort ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if (error) {
        TTLog(@"Eror occured while fetching items. Error: %@", [error localizedDescription]);
    }
    
    return result;
}

- (void)saveChanges
{
    NSError *error = nil;
    
    //Save the in memory items to the database
    [context save:&error];
    
    if (error)
    {
        TTLog(@"Error occurred while saving. Error: %@", [error localizedDescription]);
    }
}

- (NSDate *)getDateOnly {
    NSDate *date = [NSDate date];
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

@end
