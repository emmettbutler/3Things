//
//  TTNetManager.h
//  3Things
//
//  Created by Emmett Butler on 11/4/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTNetManager;
@protocol TTNetManagerDelegate <NSObject>
@optional
-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error;
@end

id <TTNetManagerDelegate> netDelegate;

@interface TTNetManager : NSObject <NSURLConnectionDelegate>
{
    NSString *rootURL;
}

+(TTNetManager *)sharedInstance;
-(id)init;
-(NSURLResponse *)apiConnectionWithURL:(NSString *)url;
-(NSURLResponse *)registerUser:(NSString *)email withName:(NSString *)uname andPassword:(NSString *)pw andPasswordConf:(NSString *)pwConf;

@property (nonatomic, assign) id <TTNetManagerDelegate> netDelegate;

@end