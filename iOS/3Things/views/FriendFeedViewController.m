//
//  FriendFeedViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "FriendFeedViewController.h"
#import "My3ThingsViewController.h"
#import "SingleDayViewController.h"
#import "UserStore.h"
#import "AppDelegate.h"
#import "UserHistoryViewController.h"
#import "My3ThingsViewController.h"
#import "LoginTypePickerViewController.h"
#import "BackgroundLayer.h"
#import "TTTableView.h"

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController

- (id)init {
    if(self = [super init]) {
        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR],
                                                              UITextAttributeTextColor,
                                                              [UIFont fontWithName:HEADER_FONT size:14.0],
                                                              UITextAttributeFont,
                                                              nil] forState:UIControlStateNormal];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    inSearch = NO;
    self.feedData = nil;
    self.parsedFeed = [[NSMutableArray alloc] init];
	
    self.navigationController.navigationBar.barTintColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"LOGOUT" style:UIBarButtonItemStylePlain target:self action:@selector(logoutWasTouched)];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
	CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    bgLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(screenFrame.size.width, 60);
    
    UIView *titleView = [[UIView alloc] init];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(-55, -20, 105, 35)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [titleView addSubview:logoView];
    self.navigationItem.titleView = titleView;
    UIImage *friendImage = [UIImage imageNamed:@"Add Friend Icon.png"];
    UIButton *friend = [UIButton buttonWithType:UIButtonTypeCustom];
    [friend addTarget:self action:@selector(friendSearchWasTouched) forControlEvents:UIControlEventTouchUpInside];
    friend.bounds = CGRectMake(0, 0, friendImage.size.width*.3, friendImage.size.height*.3);
    [friend setImage:friendImage forState:UIControlStateNormal];
    UIBarButtonItem *friendBtn = [[UIBarButtonItem alloc] initWithCustomView:friend];
    [[self navigationItem] setLeftBarButtonItem:friendBtn];
    
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getFriendFeed];
    
    int searchBoxHeight = 50;
    CGRect scrollFrame = CGRectMake(11, 0, frame.size.width*.9, screenFrame.size.height-35);
    self.tableView = [[TTTableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    // to re-enable feed element selection at daily granularity, change the following property to YES and uncomment touchesEnded in TTTableView
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    CGRect searchFieldFrame = CGRectMake(0, 65, screenFrame.size.width, searchBoxHeight-5);
    searchBox = [[UITextField alloc] initWithFrame:searchFieldFrame];
    searchBox.placeholder = @"Search";
    searchBox.delegate = self;
    searchBox.font = [UIFont fontWithName:SCRIPT_FONT size:15];
    searchBox.borderStyle = UITextBorderStyleRoundedRect;
    searchBox.clearButtonMode = UITextFieldViewModeWhileEditing;
    [searchBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    searchBox.hidden = YES;
    searchBox.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"dddddd"];
    searchBox.layer.masksToBounds = YES;
    searchBox.layer.borderColor = [[[TTNetManager sharedInstance] colorWithHexString:@"ababab"] CGColor];
    searchBox.layer.borderWidth = 4;
    searchBox.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:searchBox];
    
    navViewController = [[BottomNavViewController alloc] initWithScreen:kFriendsScreen];
    navViewController.navDelegate = self;
    [self addChildViewController:navViewController];
    [self.view addSubview:navViewController.view];
    navViewController.view.frame = navViewController.frame;
    [navViewController didMoveToParentViewController:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //[self dismissSearchWasTouched];
    [searchBox endEditing:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    inSearch = YES;
    [navViewController.view removeFromSuperview];
    self.searchViewController = [[FriendSearchViewController alloc] init];
    [self addChildViewController:self.searchViewController];
    self.searchView = self.searchViewController.view;
    [self.view addSubview:self.searchView];
    self.searchViewController.searchDelegate = self;
    self.feedDelegate = self.searchViewController;
    self.searchViewController.view.frame = self.searchViewController.frame;
    [self.searchViewController didMoveToParentViewController:self];
    [self.view addSubview:navViewController.view];
}

-(void)textFieldDidChange:(UITextField *)field {
    [self.feedDelegate searchQueryChanged:field.text];
}

-(void)dismissSearchWasTouched {
    TTLog(@"Dismiss was called");
    [self.searchViewController.inviteView removeFromSuperview];
    [self.searchViewController.tableView removeFromSuperview];
    [self.searchView removeFromSuperview];
    [searchBox endEditing:YES];
    searchBox.text = @"";
    CGRect frame = self.tableView.frame;
    frame.origin.y = oldY;
    searchBox.hidden = YES;
    self.tableView.frame = frame;
    [TTNetManager sharedInstance].netDelegate = nil;
}

-(void)logoutWasTouched
{
    if (!self.isViewLoaded) return;
    [FBSession.activeSession closeAndClearTokenInformation];
    [[TTNetManager sharedInstance] logoutToken];
    [[self navigationController] pushViewController:[[LoginTypePickerViewController alloc] init] animated:YES];
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url
{
    if (error == NULL) {
        if ([[url absoluteString] rangeOfString:[NSString stringWithFormat:@"%@/days", [TTNetManager sharedInstance].rootURL]].location == NSNotFound) {
            return;
        }

        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];

        self.feedData = json;
        for (int i = 0; i < [self.feedData[@"data"][@"history"] count]; i++){
            TTLog(@"day: %@", self.feedData[@"data"][@"history"][i]);
            NSMutableDictionary *dayAndUser = [[NSMutableDictionary alloc] init];
            TTShareDay *shareDay = [[TTShareDay alloc] initWithSharesDictionary:self.feedData[@"data"][@"history"][i]];
            [dayAndUser setObject:shareDay forKey:@"day"];
            UserStore *userStore = [[UserStore alloc] init];
            User *user = [userStore newUserFromDictionary:self.feedData[@"data"][@"history"][i][@"user"]];
            [dayAndUser setObject:user forKey:@"user"];
            [self.parsedFeed addObject:dayAndUser];
        }
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedData == nil || [self.feedData[@"data"][@"history"] count] == 0){
        return 1;
    } else {
        return [self.feedData[@"data"][@"history"] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 410;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    if (self.feedData == nil || [self.feedData[@"data"][@"history"] count] == 0) {
        UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 100)];
        emptyView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressWheel.png"]];
        spinner.frame = CGRectMake(emptyView.frame.size.width/2-100/2-10, 0, 100, 100);
        CABasicAnimation *rotation;  // http://stackoverflow.com/a/12112975/735204
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        rotation.duration = 1.7;
        rotation.repeatCount = HUGE_VALF;
        [spinner.layer addAnimation:rotation forKey:@"Spin"];
        [emptyView addSubview:spinner];
        [container addSubview:emptyView];
    } else {
        NSMutableDictionary *dayAndUser = self.parsedFeed[indexPath.row];
        SingleDayViewController *dayView = [[SingleDayViewController alloc] initWithShareDay:dayAndUser[@"day"] andIsCurrent:@(NO) andUser:dayAndUser[@"user"]];
        [self addChildViewController:dayView];
        [container addSubview:dayView.view];
        dayView.view.frame = CGRectMake(0, 0, dayView.frame.size.width, frame.size.height);
        [dayView didMoveToParentViewController:self];
        
        [container addSubview:dayView.view];
    }
    
    container.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    
    cell.backgroundView = container;
    cell.backgroundColor = [UIColor clearColor];
    //cell.selectedBackgroundView = [[UIView alloc] init];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isViewLoaded) return;
    if(self.feedData == nil) return;
     NSMutableDictionary *dayAndUser = self.parsedFeed[indexPath.row];
    [[self navigationController] pushViewController:
     [[My3ThingsViewController alloc] initWithShareDay:dayAndUser[@"day"]
                                          andIsCurrent:@(NO)
                                               andUser:dayAndUser[@"user"]]
                                           animated:YES];
}

-(void) reviewWasTouched {
    if (!self.isViewLoaded) return;
    UserStore *userStore = [[UserStore alloc] init];
    /*NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
    [viewControllers removeLastObject];
    [viewControllers addObject:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:@(YES) andUser:[userStore getAuthenticatedUser]]];
    [[self navigationController] setViewControllers:viewControllers animated:YES];*/
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:@(YES) andUser:[userStore getAuthenticatedUser]] animated:YES];
}

-(void) friendsWasTouched {
    if (!self.isViewLoaded) return;
    if (inSearch){
        NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
        [viewControllers removeLastObject];
        [viewControllers addObject:[[FriendFeedViewController alloc] init]];
        [[self navigationController] setViewControllers:viewControllers animated:YES];
        //[[self navigationController] pushViewController:[[FriendFeedViewController alloc] init] animated:YES];
    }
}

-(void) calendarWasTouched {
    if (!self.isViewLoaded) return;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
    [viewControllers removeLastObject];
    [viewControllers addObject:[[UserHistoryViewController alloc] init]];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
    //[[self navigationController] pushViewController:[[UserHistoryViewController alloc] init] animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    TTLog(@"Touch outside of table");
    [self.nextResponder touchesBegan:touches withEvent:event];
}

-(void)friendSearchWasTouched
{
    CGRect frame = self.tableView.frame;
    if (searchBox.hidden){
        searchBox.hidden = NO;
        frame.origin.y = 50;
        self.tableView.frame = frame;
        [TTNetManager sharedInstance].netDelegate = nil;
        [self textFieldDidBeginEditing:searchBox];
    } else if (searchBox.hidden == NO) {
        searchBox.hidden = YES;
        [self friendsWasTouched];
    }
}

-(void)tableTouchesEnded:(NSSet *)touches
{
}

-(void) didReceiveMemoryWarning {
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    [viewControllers addObject:self];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

@end
