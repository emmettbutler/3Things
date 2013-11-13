//
//  TTNetManager.m
//  3Things
//
//  Created by Emmett Butler on 11/4/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTNetManager.h"

@implementation TTNetManager
@synthesize netDelegate;

TTNetManager *instance;

-(void)loginToken:(NSString *)access_token
{
    self.currentAccessToken = access_token;
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:[NSString stringWithFormat:@"%d", kAccessToken]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)registerUser:(NSString *)email withName:(NSString *)uname andPassword:(NSString *)pw andPasswordConf:(NSString *)pwConf
{
    uname = [self urlEncodeString:uname];
    pw = [self urlEncodeString:pw];
    pwConf = [self urlEncodeString:pwConf];
    NSString *url = [NSString stringWithFormat:@"%@/register?identifier=%@&name=%@&pw=%@&pwc=%@",
                      rootURL, email, uname, pw, pwConf];
    TTLog(@"Attempting to register user with URL: '%@'", url);
    [self apiConnectionWithURL:url authorized:NO];
}

-(void)loginUser:(NSString *)email withPassword:(NSString *)pw
{
    NSString *url = [NSString stringWithFormat:@"%@/login?email=%@&pw=%@",
                     rootURL, email, pw];
    TTLog(@"Attempting to login user with URL: '%@'", url);
    [self apiConnectionWithURL:url authorized:NO];
}

-(void)friendSearch:(NSString *)query
{
    NSString *url = [NSString stringWithFormat:@"%@/users?q=%@",
                     rootURL, query];
    TTLog(@"Attempting to search for users");
    [self apiConnectionWithURL:url authorized:NO];
}

-(void)postShareDay:(TTShareDay *)shares forUser:(NSString *)userID
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/days", rootURL, userID];
    TTLog(@"Attempting to post day to URL %@", url);
    TTLog(@"Posting day: %@", shares);
    TTLog(@"Current access token: %@", self.currentAccessToken);
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970] ] forKey:@"time"];
    [jsonDict setObject:shares.theThings forKey:@"things"];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (! data) {
        TTLog(@"Error encoding JSON for day POST: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self apiConnectionWithURL:url andData:jsonString authorized:YES];
    }
}

-(void)getFriendFeedForUser:(NSString *)userID
{
    NSString *url = [NSString stringWithFormat:@"%@/days", rootURL];
    TTLog(@"Attempting to retrieve friends feed");
    [self apiConnectionWithURL:url authorized:YES];
}

-(void)addFriend:(NSString *)friendID forUser:(User *)user
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/friends/%@", rootURL, user.userID, friendID];
    TTLog(@"Attempting to add friend for user %@", user.userID);
    [self apiConnectionWithURL:url authorized:YES withMethod:@"PUT"];
}

-(void)removeFriend:(NSString *)friendID forUser:(User *)user
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/friends/%@", rootURL, user.userID, friendID];
    TTLog(@"Attempting to remove friend for user %@", user.userID);
    [self apiConnectionWithURL:url authorized:YES withMethod:@"DELETE"];
}

-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth withMethod:(NSString *)httpMethod
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:httpMethod];
    if (auth){
        [request setValue:[NSString stringWithFormat:@"bearer %@", self.currentAccessToken] forHTTPHeaderField:@"Authorization"];
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         // TODO - this whole delegate idea only works if there is only ever one web request happening at a time
         // doing more than one at a time would break this.
         // To allow more than one at a time, maintain a dictionary of delegates and delegate each request to the
         // appropriate one
         [netDelegate dataWasReceived:response withData:data andError:error andOriginURL:[NSURL URLWithString:url]];
      }
     ];
}

-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth{
    [self apiConnectionWithURL:url authorized:auth withMethod:@"GET"];
}

-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data authorized:(BOOL)auth{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    NSString *requestString = data;
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    if (auth){
        [request setValue:[NSString stringWithFormat:@"bearer %@", self.currentAccessToken] forHTTPHeaderField:@"Authorization"];
    }
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    __block NSError *err = nil;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         err = error;
     }
     ];
}

-(id)init{
    @synchronized(self){
        if(self = [super init]){
            self.currentAccessToken = nil;
            rootURL = @"http://localhost:8888";
        }
        return self;
    }
}

+(TTNetManager *)sharedInstance{
    @synchronized(self){
        if(instance == nil){
            return [[TTNetManager alloc] init];
        }
        return instance;
    }
}

// singleton boilerplate

+(id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (instance == nil){
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

// helpers

-(NSString *)urlEncodeString:(NSString *)string{
    NSString *retval = (NSString *)CFBridgingRelease(
                                                     CFURLCreateStringByAddingPercentEscapes(
                                                                                             NULL,
                                                                                             (__bridge CFStringRef) string,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8
                                                                                             ));
    return retval;
}

@end
