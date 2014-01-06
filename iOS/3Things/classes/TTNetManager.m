//
//  TTNetManager.m
//  3Things
//
//  Created by Emmett Butler on 11/4/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTNetManager.h"
#import <AssetsLibrary/ALAsset.h>

@implementation TTNetManager
@synthesize netDelegate;
@synthesize rootURL;

TTNetManager *instance;

-(void)loginToken:(NSString *)access_token
{
    self.currentAccessToken = access_token;
    [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:[NSString stringWithFormat:@"%d", kAccessToken]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)logoutToken
{
    self.currentAccessToken = NULL;
    [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:[NSString stringWithFormat:@"%d", kAccessToken]];
    [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
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

-(void)registerUserWithFacebookID:(NSString *)facebookID andName:(NSString *)name
{
    name = [self urlEncodeString:name];
    facebookID = [self urlEncodeString:facebookID];
    NSString *url = [NSString stringWithFormat:@"%@/fblogin?fbid=%@&name=%@",
                     rootURL, facebookID, name];
    TTLog(@"Attempting to register Facebook user with URL: '%@'", url);
    [self apiConnectionWithURL:url authorized:NO];
}

-(void)loginUser:(NSString *)email withPassword:(NSString *)pw andImage:(NSString *)imageURL
{
    NSString *url = [NSString stringWithFormat:@"%@/login", rootURL];
    NSError *error;
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    
    [jsonDict setObject:email forKey:@"email"];
    [jsonDict setObject:pw forKey:@"pw"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    if (imageURL == nil) {
        TTLog(@"Attempting to login user with URL: '%@'", url);
        [self apiConnectionWithURL:url andData:jsonString andImages:nil authorized:NO fileName:@"userpic" jsonFilename:@"login"];
        return;
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[NSURL URLWithString:imageURL] resultBlock:^(ALAsset *asset )
     {
         UIImage *theImage = [UIImage imageWithCGImage:[asset thumbnail]];
         [images addObject:theImage];
         TTLog(@"Attempting to login user with URL: '%@'", url);
         [self apiConnectionWithURL:url andData:jsonString andImages:images authorized:NO fileName:@"userpic" jsonFilename:@"login"];
     }
            failureBlock:^(NSError *error )
     {
         TTLog(@"Error loading asset");
     }];
}

-(void)friendSearch:(NSString *)query forUser:(User *)user
{
    NSString *url = [NSString stringWithFormat:@"%@/users?q=%@&uid=%@",
                     rootURL, query, [user userID]];
    TTLog(@"Attempting to search for users");
    [self apiConnectionWithURL:url authorized:NO];
}

-(void)getCommentsForThing:(NSNumber *)index withDay:(NSString *)dayID
{
    NSString *url = [NSString stringWithFormat:@"%@/days/%@/comments?index=%d",
                     rootURL, dayID, [index intValue]];
    TTLog(@"Attempting to get comments for day %@ thing %d", dayID, [index intValue]);
    [self apiConnectionWithURL:url authorized:YES];
}

-(void)postCommentForThing:(NSNumber *)index withDay:(NSString *)dayID andUser:(User *)user andText:(NSString *)text
{
    NSString *url = [NSString stringWithFormat:@"%@/days/%@/comments?index=%d", rootURL, dayID, [index intValue]];
    TTLog(@"Attempting to post comment to URL %@", url);
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    jsonDict[@"time"] = [dateFormatter stringFromDate:[NSDate date]];
    jsonDict[@"text"] = text;
    jsonDict[@"uid"] = user.userID;
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (!data) {
        TTLog(@"Error encoding JSON for day POST: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self apiConnectionWithURL:url andData:jsonString authorized:YES];
    }
}

-(void)postShareDay:(TTShareDay *)shares forUser:(NSString *)userID
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/days", rootURL, userID];
    TTLog(@"Attempting to post day to URL %@", url);
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    [jsonDict setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"time"];
    [jsonDict setObject:shares.theThings forKey:@"things"];
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (!data) {
        TTLog(@"Error encoding JSON for day POST: %@", error);
    } else {
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        for (NSDictionary *thing in shares.theThings) {
            NSString *img = thing[@"localImageURL"];
            int index = [shares.theThings indexOfObject:thing];
            TTLog(@"Attempting to get thing image");
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[NSURL URLWithString:img] resultBlock:^(ALAsset *asset )
            {
                UIImage *theImage = [UIImage imageWithCGImage:[asset thumbnail]];
                if (theImage != NULL) {
                    [images insertObject:theImage atIndex:index];
                } else {
                    [images insertObject:[NSNull null] atIndex:index];
                }
                if (index == 2){
                    [self apiConnectionWithURL:url andData:jsonString andImages:images authorized:YES fileName:@"thingimage" jsonFilename:@"day"];
                }
            }
                failureBlock:^(NSError *error )
            {
                TTLog(@"Error loading asset");
            }];
        }
    }
}

-(void)getTodayForUser:(User *)user
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/today", rootURL, [user userID]];
    TTLog(@"Attempting to get today for user %@", [user userID]);
    [self apiConnectionWithURL:url authorized:YES];
}

-(void)getHistoryForUser:(NSString *)userID
{
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/days", rootURL, userID];
    TTLog(@"Attempting to get history for user %@", userID);
    [self apiConnectionWithURL:url authorized:YES];
}

-(void)getFriendFeedForUser:(NSString *)userID
{
    NSString *url = [NSString stringWithFormat:@"%@/days", rootURL];
    TTLog(@"Attempting to retrieve friends feed for user %@", userID);
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

-(void)getRegisteredFacebookFriends:(User *)user withFriendIDs:(NSArray *)friendIDs andQuery:(NSString *)query
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    NSError *error;
    [jsonDict setObject:friendIDs forKey:@"friends"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"%@/users/%@/friends/facebook/%@", rootURL, user.userID, query];
    TTLog(@"Attempting to retrieve registered facebook friends for user %@", user.userID);
    [self apiConnectionWithURL:url andData:jsonString authorized:YES];
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
         // Or, fix some tiny issues by terminating any current request every time a new one is started
         [netDelegate dataWasReceived:response withData:data andError:error andOriginURL:[NSURL URLWithString:url]];
      }
     ];
}

-(void)apiConnectionWithURL:(NSString *)url authorized:(BOOL)auth{
    [self apiConnectionWithURL:url authorized:auth withMethod:@"GET"];
}

-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data authorized:(BOOL)auth
{
    [self apiConnectionWithURL:url andData:data andImages:nil authorized:auth fileName:@"data" jsonFilename:@"jsondata"];
}

-(void)apiConnectionWithURL:(NSString *)url andData:(NSString *)data andImages:(NSArray *)images authorized:(BOOL)auth fileName:(NSString *)filename jsonFilename:(NSString *)jsonFilename{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    NSString *requestString = data;
    NSMutableData *postData = [NSMutableData data];
    [postData appendData:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"-----------------------------asidugyasd87gya9sd87ygah9s7ygha", *FileParamConstant = filename;
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    if (auth){
        [request setValue:[NSString stringWithFormat:@"bearer %@", self.currentAccessToken] forHTTPHeaderField:@"Authorization"];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"day.json\"\r\n\r\n", jsonFilename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", data] dataUsingEncoding:NSUTF8StringEncoding]];
    
    BOOL hasEnded = NO, addedImage = NO;
    if (images != nil) {
        for (UIImage *image in images) {
            if (image != (UIImage *)[NSNull null]){
                NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
                if (imageData) {
                    addedImage = YES;
                    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%d.jpg\"\r\n", FileParamConstant, [images indexOfObject:image]] dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                    [body appendData:imageData];
                    hasEnded = YES;
                    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
    }
    if (!hasEnded) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error){
         [self.netDelegate dataWasReceived:response withData:data andError:error andOriginURL:[NSURL URLWithString:url]];
     }
     ];
}

-(id)init{
    @synchronized(self){
        if(self = [super init]){
            self.currentAccessToken = nil;
            //rootURL = @"http://localhost:5000";
            rootURL = @"http://three-things.herokuapp.com";
            self.rootURL = rootURL;
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

-(UIColor *)colorWithHexString:(NSString *)hex opacity:(CGFloat)op
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:(float)op];
}

// http://stackoverflow.com/questions/6207329/how-to-set-hex-color-code-for-background
-(UIColor*)colorWithHexString:(NSString*)hex
{
    return [self colorWithHexString:hex opacity:1];
}

@end
