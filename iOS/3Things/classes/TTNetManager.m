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


-(NSURLResponse *)registerUser:(NSString *)email withName:(NSString *)uname andPassword:(NSString *)pw andPasswordConf:(NSString *)pwConf
{
    NSString *url = [NSString stringWithFormat:@"%@/register?identifier=%@&name=%@&pw=%@&pwc=%@",
                      rootURL, email, uname, pw, pwConf];
    NSLog(@"Attempting to register user with URL: '%@'", url);
    NSURLResponse *res = [self apiConnectionWithURL:url];
    return res;
}

-(NSURLResponse *)apiConnectionWithURL:(NSString *)url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         [netDelegate dataWasReceived:response withData:data andError:error];
     }
     ];
    return nil;
}

-(id)init{
    @synchronized(self){
        if(self = [super init]){
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

@end
