//
//  User.h
//  3Things
//
//  Created by Emmett Butler on 10/20/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * profileImageLocalURL;

@end
