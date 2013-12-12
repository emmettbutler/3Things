//
//  FriendSearchViewController.m
//  3Things
//
//  Created by Emmett Butler on 11/13/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "FriendSearchViewController.h"
#import "FriendFeedViewController.h"
#import "UserStore.h"
#import "BackgroundLayer.h"
#import "AppDelegate.h"
#import "TTNetManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FriendSearchViewController ()

@end

@implementation FriendSearchViewController
@synthesize searchDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lastSearchTime = 0;
    self.friendData = [[NSMutableArray alloc] init];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, 110, screenFrame.size.width, screenFrame.size.height);
    self.frame = popupFrame;
    
    [TTNetManager sharedInstance].netDelegate = self;
    
    CGRect inviteFrame = CGRectMake(0, self.frame.size.height-300, self.frame.size.width, 300);
    UIView *inviteView = [[UIView alloc] initWithFrame:inviteFrame];
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    bgLayer.frame = inviteFrame;
    inviteView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"e0e1e2"];
    [inviteView.layer insertSublayer:bgLayer atIndex:0];
    UITextView *prompt = [[UITextView alloc] init];
    prompt.frame = CGRectMake(0, 20, self.frame.size.width, 30);
    prompt.textAlignment = NSTextAlignmentCenter;
    prompt.text = @"Can't find who you're looking for?";
    prompt.font = [UIFont fontWithName:SCRIPT_FONT size:17];
    prompt.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [inviteView addSubview:prompt];
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [inviteButton addTarget:self
                    action:@selector(inviteWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [inviteButton setTitle:@"INVITE VIA FACEBOOK" forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(screenFrame.size.width/2-170/2, 70, 170, 35);
    inviteButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    inviteButton.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"c3c3c3"];
    inviteButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [inviteView addSubview:inviteButton];
    [inviteButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
    [self.view addSubview:inviteView];
    
    CGRect scrollFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-270);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    UserStore *userStore = [[UserStore alloc] init];
    TTLog(@"Checking FB session: %@", FBSession.activeSession);
    if (FBSession.activeSession.isOpen || FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded){
        TTLog(@"Session open");
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
        {
            [FBSession.activeSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                                    completionHandler:^(FBSession *session,
                                                        FBSessionState state, NSError *error) {
                                    }];
        }
        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary* result,
                                                      NSError *error) {
            NSArray* friends = [result objectForKey:@"data"];
            NSMutableArray *friendIDs = [[NSMutableArray alloc] init];
            TTLog(@"friends count: %d, error %@", [friends count], error);
            for (NSDictionary<FBGraphUser>* friend in friends) {
                [friendIDs addObject:friend.id];
            }
            [[TTNetManager sharedInstance] getRegisteredFacebookFriends:[userStore getAuthenticatedUser] withFriendIDs:friendIDs andQuery:@""];
        }];
    }
    [[TTNetManager sharedInstance] friendSearch:@"" forUser:[userStore getAuthenticatedUser]];
}

- (void)inviteWasTouched
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [searchDelegate dismissSearchWasTouched];
}

- (void)searchQueryChanged:(NSString *)text
{
    lastSearchTime = [[NSDate date] timeIntervalSince1970];
    self.friendData = [[NSMutableArray alloc] init];
    UserStore *userStore = [[UserStore alloc] init];
    [[TTNetManager sharedInstance] friendSearch:text forUser:[userStore getAuthenticatedUser]];
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSMutableArray *friendIDs = [[NSMutableArray alloc] init];
        TTLog(@"friends count: %d, error %@", [friends count], error);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            [friendIDs addObject:friend.id];
        }
        [[TTNetManager sharedInstance] getRegisteredFacebookFriends:[userStore getAuthenticatedUser] withFriendIDs:friendIDs andQuery:text];
    }];
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url {
    if (error == NULL) {
        UserStore *userStore = [[UserStore alloc] init];
        TTLog(@"Data received from %@", url);
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];
        TTLog(@"json response: %@", json);
        for (NSDictionary *user in (NSArray *)[json objectForKey:@"data"]){
            BOOL found = NO;
            NSString *thisUserID = [user objectForKey:@"_id"];
            for (NSDictionary *existingUser in self.friendData){
                if ([thisUserID isEqualToString:[existingUser objectForKey:@"_id"]]){
                    found = YES;
                }
            }
            if ([thisUserID isEqualToString:[[userStore getAuthenticatedUser] userID]]) {
                found = YES;
            }
            if (!found) {
                if ([url.path isEqualToString:[NSString stringWithFormat:@"/users/%@/friends/facebook", [[userStore getAuthenticatedUser] userID]]]) {
                    [self.friendData insertObject:user atIndex:0];
                } else {
                    [self.friendData addObject:user];
                }
            }
        }
        [self.tableView reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.friendData == nil){
        return 2;
    } else {
        return [self.friendData count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];

    if (self.friendData == nil) return cell;
    
    NSDictionary *user = [self.friendData objectAtIndex:indexPath.row];
    
    CGRect picFrame = CGRectMake(20, 15, 40, 40);
    UIView *profilePicView;
    if ([user objectForKey:@"fbid"] != NULL && ![[user objectForKey:@"fbid"] isEqualToString:@""]) {
        TTLog(@"Using facebook profile image");
        profilePicView = [[FBProfilePictureView alloc] initWithProfileID:[user objectForKey:@"facebookID"] pictureCropping:FBProfilePictureCroppingSquare];
        profilePicView.frame = picFrame;
    } else {
        TTLog(@"Looking up profile image %@", [user objectForKey:@"profileImageID"]);
        NSURL *url = [NSURL URLWithString:[user objectForKey:@"profileImageID"]];
        profilePicView = [[UIImageView alloc] initWithFrame:picFrame];
        NSURL *picURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [TTNetManager sharedInstance].rootURL, [url absoluteString]]];
        TTLog(@"Looking up image %@", picURL);
        [(UIImageView *)profilePicView setImageWithURL:picURL
                                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    CALayer *imageLayer = profilePicView.layer;
    [imageLayer setCornerRadius:profilePicView.frame.size.width/2];
    [imageLayer setMasksToBounds:YES];
    [container addSubview:profilePicView];
    
    UITextView *thingTextView = [[UITextView alloc] initWithFrame:CGRectMake(70, 18, 160, 40)];
    [thingTextView setText:[[user objectForKey:@"name"] uppercaseString]];
    thingTextView.font = [UIFont fontWithName:HEADER_FONT size:14];
    thingTextView.textColor = [[TTNetManager sharedInstance] colorWithHexString:@"333333"];
    [container addSubview:thingTextView];
    
    UITextView *followText = [[UITextView alloc] initWithFrame:CGRectMake(230, 15, 100, 40)];
    [followText setText:@"FOLLOW"];
    followText.font = [UIFont fontWithName:HEADER_FONT size:14];
    followText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    [container addSubview:followText];
    
    cell.backgroundView = container;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTLog(@"Selected search item %d", indexPath.row);
    
    UserStore *userStore = [[UserStore alloc] init];
    NSDictionary *user = [self.friendData objectAtIndex:indexPath.row];
    [[TTNetManager sharedInstance] addFriend:[user objectForKey:@"_id"] forUser:[userStore getAuthenticatedUser]];
    
    [searchDelegate dismissSearchWasTouched];
}

@end