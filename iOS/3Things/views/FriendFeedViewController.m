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
#import "UserHistoryViewController.h"
#import "My3ThingsViewController.h"
#import "LoginTypePickerViewController.h"
#import "BackgroundLayer.h"

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.feedData = nil;
    self.parsedFeed = [[NSMutableArray alloc] init];
	
    self.navigationController.navigationBar.barTintColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"LOGOUT" style:UIBarButtonItemStylePlain target:self action:@selector(logoutWasTouched)];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR],
                                                          UITextAttributeTextColor,
                                                          [UIFont fontWithName:HEADER_FONT size:14.0],
                                                          UITextAttributeFont,
                                                          nil] forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
	CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    bgLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50);
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(screenFrame.size.width, 60);
    
    UIView *titleView = [[UIView alloc] init];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(-65, -20, 120, 40)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [titleView addSubview:logoView];
    self.navigationItem.titleView = titleView;
    
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getFriendFeedForUser:nil];
    
    int searchBoxHeight = 50;
    CGRect scrollFrame = CGRectMake(11, 0, frame.size.width*.9, screenFrame.size.height-35);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    touchView = [[TTView alloc] initWithFrame:CGRectMake(scrollFrame.origin.x, scrollFrame.origin.y+50, scrollFrame.size.width, 70)];
    touchView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    touchView.touchDelegate = self;
    [self.view addSubview:touchView];
    
    CGRect searchFieldFrame = CGRectMake(0, 60, screenFrame.size.width, searchBoxHeight);
    searchBox = [[UITextField alloc] initWithFrame:searchFieldFrame];
    searchBox.placeholder = @"Search";
    searchBox.delegate = self;
    searchBox.borderStyle = UITextBorderStyleRoundedRect;
    searchBox.clearButtonMode = UITextFieldViewModeWhileEditing;
    [searchBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    searchBox.hidden = YES;
    [self.view addSubview:searchBox];
    
    BottomNavViewController *navViewController = [[BottomNavViewController alloc] init];
    navViewController.navDelegate = self;
    [self addChildViewController:navViewController];
    [self.view addSubview:navViewController.view];
    navViewController.view.frame = navViewController.frame;
    [navViewController didMoveToParentViewController:self];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.searchViewController = [[FriendSearchViewController alloc] init];
    [self addChildViewController:self.searchViewController];
    [self.view addSubview:self.searchViewController.view];
    self.searchViewController.searchDelegate = self;
    self.feedDelegate = self.searchViewController;
    self.searchViewController.view.frame = self.searchViewController.frame;
    [self.searchViewController didMoveToParentViewController:self];
}

-(void)textFieldDidChange:(UITextField *)field {
    [self.feedDelegate searchQueryChanged:field.text];
}

-(void)dismissSearchWasTouched {
    [self.searchViewController.view removeFromSuperview];
    [searchBox endEditing:YES];
    searchBox.text = @"";
}

-(void)logoutWasTouched
{
    [[TTNetManager sharedInstance] logoutToken];
    [[self navigationController] pushViewController:[[LoginTypePickerViewController alloc] init] animated:YES];
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url
{
    if (error == NULL) {
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];
        TTLog(@"json response: %@", json);
        self.feedData = json;
        for (int i = 0; i < [[[self.feedData objectForKey:@"data"] objectForKey:@"history"] count]; i++){
            NSMutableDictionary *dayAndUser = [[NSMutableDictionary alloc] init];
            TTShareDay *shareDay = [[TTShareDay alloc] initWithSharesDictionary:
                                    [[[self.feedData objectForKey:@"data"] objectForKey:@"history"] objectAtIndex:i]];
            [dayAndUser setObject:shareDay forKey:@"day"];
            UserStore *userStore = [[UserStore alloc] init];
            User *user = [userStore newUserFromDictionary:[[[[self.feedData objectForKey:@"data"] objectForKey:@"history"] objectAtIndex:i] objectForKey:@"user"]];
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
    if (self.feedData == nil){
        return 2;
    } else {
        return [[[self.feedData objectForKey:@"data"] objectForKey:@"history"] count];
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
    
    if (self.feedData == nil) return cell;
    
    NSMutableDictionary *dayAndUser = [self.parsedFeed objectAtIndex:indexPath.row];
    SingleDayViewController *dayView = [[SingleDayViewController alloc] initWithShareDay:
                                        [dayAndUser objectForKey:@"day"] andIsCurrent:[NSNumber numberWithBool:NO] andUser:[dayAndUser objectForKey:@"user"]];
    [self addChildViewController:dayView];
    [container addSubview:dayView.view];
    dayView.view.frame = CGRectMake(0, 0, dayView.frame.size.width, frame.size.height);
    [dayView didMoveToParentViewController:self];
    
    [container addSubview:dayView.view];
    
    container.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    
    cell.backgroundView = container;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [[UIView alloc] init];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
     NSMutableDictionary *dayAndUser = [self.parsedFeed objectAtIndex:indexPath.row];
    [[self navigationController] pushViewController:
     [[My3ThingsViewController alloc] initWithShareDay:[dayAndUser objectForKey:@"day"]
                                          andIsCurrent:[NSNumber numberWithBool:NO]
                                               andUser:[dayAndUser objectForKey:@"user"]]
                                           animated:YES];
}

-(void) reviewWasTouched {
    UserStore *userStore = [[UserStore alloc] init];
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES] andUser:[userStore getAuthenticatedUser]] animated:YES];
}

-(void) friendsWasTouched {
    TTLog(@"Friend feed selected on friends page. Do nothing???");
}

-(void) calendarWasTouched {
    [[self navigationController] pushViewController:[[UserHistoryViewController alloc] init] animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch outside of table");
}

-(void)tableTouchesBegan:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    NSLog(@"Touch in table");
    if (touchLocation.y < self.tableView.frame.origin.y+90){
        dragging = YES;
        touchLastY = touchLocation.y;
        if(searchBox.hidden){
            oldY = self.tableView.frame.origin.y;
        }
    }
}

-(void)tableTouchesMoved:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    if(dragging){
        CGRect frame = self.tableView.frame;
        CGRect touchFrame = touchView.frame;
        if (searchBox.hidden && touchLastY < touchLocation.y){
            searchBox.hidden = NO;
            frame.origin.y = 50;
            touchFrame.origin.y = 110;
            touchView.frame = touchFrame;
            self.tableView.frame = frame;
        } else if (searchBox.hidden == NO  && touchLastY > touchLocation.y) {
            frame.origin.y = oldY;
            touchFrame.origin.y = oldY+50;
            touchView.frame = touchFrame;
            searchBox.hidden = YES;
            self.tableView.frame = frame;
        }
        dragging = NO;
    }
}

-(void)tableTouchesEnded:(NSSet *)touches
{
}

@end
