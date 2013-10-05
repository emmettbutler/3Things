//
//  ShareDay.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Thing;

@interface ShareDay : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Thing *thing1;
@property (nonatomic, retain) Thing *thing2;
@property (nonatomic, retain) Thing *thing3;

@end
