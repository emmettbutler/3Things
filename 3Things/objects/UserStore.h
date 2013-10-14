//
//  UserStore.h
//  3Things
//
//  Created by Emmett Butler on 10/6/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTDataStore.h"
#import "User.h"

@interface UserStore : TTDataStore

- (NSArray *)allUsers;
- (User *)createUser:(NSNumber *)identifier withName:(NSString *)name;
- (User *)getAuthenticatedUser;
+ (void)initCurrentUser;

@end
