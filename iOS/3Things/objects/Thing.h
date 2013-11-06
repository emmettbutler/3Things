//
//  Thing.h
//  3Things
//
//  Created by Emmett Butler on 11/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ShareDay;

@interface Thing : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * localImageURL;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) ShareDay *day;

@end
