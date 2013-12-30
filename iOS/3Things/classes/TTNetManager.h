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
#define COLOR_LIGHT_GRAY @"eff0f0"
#define HEADER_TEXT_COLOR @"648431"
#define HEADER_FONT @"AvenirNext-Regular"
#define HEADER_FONT_BOLD @"AvenirNext-Bold"
#define SCRIPT_FONT @"Baskerville-Italic"
#define HEADER_FONT_SIZE 15
#define BUTTON_TEXT_BLUE_COLOR @"669099"
#define COLOR_FACEBOOK @"38609e"
#define BUTTON_TEXT_SIZE 10
#define THING_TEXT_SIZE 12
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
-(UIColor *)colorWithHexString:(NSString *)hex opacity:(CGFloat)op;
-(void)loginToken:(NSString *)access_token;
-(void)logoutToken;
-(void)getRegisteredFacebookFriends:(User *)user withFriendIDs:(NSArray *)friendIDs andQuery:(NSString *)query;
-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth;
-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth withMethod:(NSString *)httpMethod;
-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data andImages:(NSArray *)images authorized:(BOOL)auth fileName:(NSString *)filename jsonFilename:(NSString *)jsonFilename;
-(void)registerUser:(NSString *)email withName:(NSString *)uname andPassword:(NSString *)pw andPasswordConf:(NSString *)pwConf;
-(void)registerUserWithFacebookID:(NSString *)facebookID andName:(NSString *)name;
-(void)loginUser:(NSString *)email withPassword:(NSString *)pw andImage:(NSString *)imageURL;
-(void)getFriendFeedForUser:(NSString *)userID;
-(void)getTodayForUser:(User *)user;
-(void)getHistoryForUser:(NSString *)userID;
-(void)postShareDay:(TTShareDay *)shares forUser:(NSString *)userID;
-(void)friendSearch:(NSString *)query forUser:(User *)user;
-(void)addFriend:(NSString *)friendID forUser:(User *)user;
-(void)removeFriend:(NSString *)friendID forUser:(User *)user;
-(void)getCommentsForThing:(NSNumber *)index withDay:(NSString *)dayID;
-(void)postCommentForThing:(NSNumber *)index withDay:(NSString *)dayID andUser:(User *)user andText:(NSString *)text;

@property (nonatomic, retain) NSString *currentAccessToken;
@property (nonatomic, retain) NSString *rootURL;
@property (nonatomic, assign) id <TTNetManagerDelegate> netDelegate;

@end