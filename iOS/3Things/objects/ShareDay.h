//
//  ShareDay.h
//  3Things
//
//  Created by Emmett Butler on 11/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thing, User;

@interface ShareDay : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Thing *thing1;
@property (nonatomic, retain) Thing *thing2;
@property (nonatomic, retain) Thing *thing3;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *things;
@end

@interface ShareDay (CoreDataGeneratedAccessors)

- (void)addThingsObject:(Thing *)value;
- (void)removeThingsObject:(Thing *)value;
- (void)addThings:(NSSet *)values;
- (void)removeThings:(NSSet *)values;

@end
