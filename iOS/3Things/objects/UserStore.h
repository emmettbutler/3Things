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
- (User *)createUser:(NSString *)uid withName:(NSString *)name andImgURL:(NSString *)profImgURL;
- (User *)getAuthenticatedUser;
- (User *)newUserFromDictionary:(NSDictionary *)userDict;
+ (void)initCurrentUser;
+ (void)initCurrentUserWithImage:(NSString *)imageURL
                        andEmail:(NSString *)email
                     andUserName:(NSString *)uname
                     andPassword:(NSString *)pw
                       andUserID:(NSString *)uid;
+ (void)initCurrentUserWithUserName:(NSString *)uname andUserID:(NSString *)uid andFBID:(NSString *)facebookID;

@end
