//
//  TTNetManager.h
//  3Things
//
//  Created by Emmett Butler on 11/4/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "TTShareDay.h"

@class TTNetManager;
@protocol TTNetManagerDelegate <NSObject>
@optional
-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url;
@end

id <TTNetManagerDelegate> netDelegate;

typedef enum _kStorage {
    kAccessToken, kDayComplete, kAuthUserID
} kStorage;

@interface TTNetManager : NSObject <NSURLConnectionDelegate>
{
    NSString *rootURL;
}

+(TTNetManager *)sharedInstance;
-(NSString *)urlEncodeString:(NSString *)string;
-(id)init;
-(void)loginToken:(NSString *)access_token;
-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth;
-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data authorized:(BOOL)auth;
-(void)registerUser:(NSString *)email withName:(NSString *)uname andPassword:(NSString *)pw andPasswordConf:(NSString *)pwConf;
-(void)loginUser:(NSString *)email withPassword:(NSString *)pw;
-(void)postShareDay:(TTShareDay *)shares forUser:(NSString *)userID;

@property (nonatomic, retain) NSString *currentAccessToken;
@property (nonatomic, assign) id <TTNetManagerDelegate> netDelegate;

@end