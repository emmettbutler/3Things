//
//  ShareDayStore.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ShareDayStore.h"
#import "AppDelegate.h"

@implementation ShareDayStore

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

- (ShareDay *)createShareDay
{
    ShareDay *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ShareDay" inManagedObjectContext:context];
    return newItem;
}

- (NSArray *)allItems
{
    //The Fetch Request is the foundation for what we'll ask Core Data for. Think of it as the shell of your question
    //We are currently saying "Core Data I want something"
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    //We ask the model (our database schema) for the information (schema) of the object we want
    NSEntityDescription *description = [[model entitiesByName] objectForKey:@"ShareDay"];
    
    //Tell our request what we are looking for. Now we are saying "Core Data I want my CDItems"
    [request setEntity:description];
    
    //This will organize our results by the field "name" we can use any field that is on the object
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error = nil;
    
    //Sends our request to core data and holds the result
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    //Reports any errors that might have occured
    if (error)
    {
        NSLog(@"Eror occured while fetching items. Error: %@", [error localizedDescription]);
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
        NSLog(@"Error occurred while saving. Error: %@", [error localizedDescription]);
    }
}

@end
