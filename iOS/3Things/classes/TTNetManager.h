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

#define TTLog( s, ... ) NSLog( @"<%@:(%d)> [3Things] %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define COLOR_YELLOW @"f5e34f"
#define BUTTON_COLOR @"f2f2f2"
#define HEADER_TEXT_COLOR @"648431"
#define HEADER_FONT @"STHeitiTC-Light"
#define HEADER_FONT_SIZE 15
#define BUTTON_TEXT_BLUE_COLOR @"669099"
#define BUTTON_TEXT_SIZE 10
#define THING_TEXT_SIZE 13
#define BUTTON_CORNER_RADIUS 3
#define KEYBOARD_HEIGHT 216

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
-(UIColor*)colorWithHexString:(NSString*)hex;
-(void)loginToken:(NSString *)access_token;
-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth;
-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth withMethod:(NSString *)httpMethod;
-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data authorized:(BOOL)auth;
-(void)registerUser:(NSString *)email withName:(NSString *)uname andPassword:(NSString *)pw andPasswordConf:(NSString *)pwConf;
-(void)loginUser:(NSString *)email withPassword:(NSString *)pw;
-(void)getFriendFeedForUser:(NSString *)userID;
-(void)getTodayForUser:(User *)user;
-(void)getHistoryForUser:(NSString *)userID;
-(void)postShareDay:(TTShareDay *)shares forUser:(NSString *)userID;
-(void)friendSearch:(NSString *)query;
-(void)addFriend:(NSString *)friendID forUser:(User *)user;
-(void)removeFriend:(NSString *)friendID forUser:(User *)user;

@property (nonatomic, retain) NSString *currentAccessToken;
@property (nonatomic, assign) id <TTNetManagerDelegate> netDelegate;

@end