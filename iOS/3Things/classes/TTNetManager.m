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

-(void)postShareDay:(TTShareDay *)shares
{
    NSLog(@"Stub of postShareDay");
}

-(NSURLResponse *)apiConnectionWithURL:(NSString *)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         [netDelegate dataWasReceived:response withData:data andError:error andOriginURL:[NSURL URLWithString:url]];
     }
     ];
    return nil;
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
