//
//  User.h
//  3Things
//
//  Created by Emmett Butler on 12/9/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ShareDay;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileImageLocalURL;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSSet *shareDays;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addShareDaysObject:(ShareDay *)value;
- (void)removeShareDaysObject:(ShareDay *)value;
- (void)addShareDays:(NSSet *)values;
- (void)removeShareDays:(NSSet *)values;

@end
