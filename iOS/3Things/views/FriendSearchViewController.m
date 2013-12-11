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
#import "AppDelegate.h"

@interface FriendSearchViewController ()

@end

@implementation FriendSearchViewController
@synthesize searchDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.friendData = nil;
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, 110, screenFrame.size.width, screenFrame.size.height-142);
    self.frame = popupFrame;
    
    [TTNetManager sharedInstance].netDelegate = self;
    
    CGRect scrollFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
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
            UserStore *userStore = [[UserStore alloc] init];
            [[TTNetManager sharedInstance] getRegisteredFacebookFriends:[userStore getAuthenticatedUser] withFriendIDs:friendIDs];
        }];
    } else {
        TTLog(@"No Facebook session found");
        [[TTNetManager sharedInstance] friendSearch:@""];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [searchDelegate dismissSearchWasTouched];
}

- (void)searchQueryChanged:(NSString *)text
{
    [[TTNetManager sharedInstance] friendSearch:text];
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
        self.friendData = json;
        [self.tableView reloadData];
//        if ([url.path isEqualToString:[NSString stringWithFormat:@"/users/%@/friends/facebook", [[userStore getAuthenticatedUser] userID]]]) {
        } else {
        }
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.friendData == nil){
        return 2;
    } else {
        return [[self.friendData objectForKey:@"data"] count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
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
    
    NSDictionary *user = [[self.friendData objectForKey:@"data"] objectAtIndex:indexPath.row];
    
    UITextView *thingTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    [thingTextView setText:[user objectForKey:@"name"]];
    [thingTextView setFont:[UIFont systemFontOfSize:20]];
    [container addSubview:thingTextView];
    
    cell.backgroundView = container;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTLog(@"Selected search item %d", indexPath.row);
    
    UserStore *userStore = [[UserStore alloc] init];
    NSDictionary *user = [[self.friendData objectForKey:@"data"] objectAtIndex:indexPath.row];
    [[TTNetManager sharedInstance] addFriend:[user objectForKey:@"_id"] forUser:[userStore getAuthenticatedUser]];
    
    [searchDelegate dismissSearchWasTouched];
}

@end