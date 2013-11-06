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
    NSLog(@"Attempting to register user with URL: '%@'", url);
    [self apiConnectionWithURL:url];
}

-(void)loginUser:(NSString *)email withPassword:(NSString *)pw
{
    NSString *url = [NSString stringWithFormat:@"%@/login?email=%@&pw=%@",
                     rootURL, email, pw];
    NSLog(@"Attempting to login user with URL: '%@'", url);
    [self apiConnectionWithURL:url];
}

-(void)postShareDay:(TTShareDay *)shares forUser:(NSString *)userID
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/days", rootURL, userID];
    NSLog(@"Attempting to post day to URL %@", url);
    NSLog(@"Posting day: %@", shares);
    NSLog(@"Current access token: %@", self.currentAccessToken);
    NSString *data = @"";
    [self apiConnectionWithURL:url andData:data];
}

-(void)apiConnectionWithURL:(NSString *)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         [netDelegate dataWasReceived:response withData:data andError:error andOriginURL:[NSURL URLWithString:url]];
     }
     ];
}

-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    NSString *requestString = data;
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
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
