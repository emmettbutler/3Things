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
#import "TTNetManager.h"
#import "UserStore.h"
#import "My3ThingsViewController.h"

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.feedData = nil;
    self.parsedFeed = [[NSMutableArray alloc] init];
	
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Friends" style:UIBarButtonItemStyleBordered target:self action:@selector(friendsWasTouched)];
	[[self navigationItem] setLeftBarButtonItem:button];
    
	CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
	[self.view addSubview:navBar];
    
    UserStore *userStore = [[UserStore alloc] init];
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getFriendFeedForUser:[NSString stringWithFormat:@"%d", [[userStore getAuthenticatedUser].identifier intValue]]];
    
    CGRect scrollFrame = CGRectMake(0, frame.size.height+10, frame.size.width, screenFrame.size.height-frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    BottomNavViewController *navViewController = [[BottomNavViewController alloc] init];
    navViewController.navDelegate = self;
    [self addChildViewController:navViewController];
    [self.view addSubview:navViewController.view];
    navViewController.view.frame = CGRectMake(0, screenFrame.size.height-30, screenFrame.size.width, 50);
    [navViewController didMoveToParentViewController:self];
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
            TTShareDay *shareDay = [[TTShareDay alloc] initWithSharesDictionary:
                                    [[[self.feedData objectForKey:@"data"] objectForKey:@"history"] objectAtIndex:i]];
            [self.parsedFeed addObject:shareDay];
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
    return 460;
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
    
    SingleDayViewController *dayView = [[SingleDayViewController alloc] initWithShareDay:
                                        [self.parsedFeed objectAtIndex:indexPath.row] andIsCurrent:[NSNumber numberWithBool:YES]];
    [self addChildViewController:dayView];
    [container addSubview:dayView.view];
    dayView.view.frame = CGRectMake(0, 0, dayView.frame.size.width, frame.size.height);
    [dayView didMoveToParentViewController:self];
    
    [container addSubview:dayView.view];
    
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TTLog(@"Opening detail view: %@", [self.parsedFeed objectAtIndex:indexPath.row]);
    [[self navigationController] pushViewController:
     [[My3ThingsViewController alloc] initWithShareDay:[self.parsedFeed objectAtIndex:indexPath.row]
                                          andIsCurrent:[NSNumber numberWithBool:NO]]
                                           animated:YES];
}

-(void) reviewWasTouched {
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES]] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
