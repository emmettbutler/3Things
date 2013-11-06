//
//  UserHistoryViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "UserHistoryViewController.h"
#import "My3ThingsViewController.h"
#import "ShareDayStore.h"
#import "Thing.h"
#import "BottomNavViewController.h"
#import "UserStore.h"
#import "TTNetManager.h"

@implementation UserHistoryViewController

- (void)viewDidLoad
{
    TTLog(@"entered userhistory controller");
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    
    ShareDayStore *store = [[ShareDayStore alloc] init];
    UserStore *userStore = [[UserStore alloc] init];
    self.userHistory = [store allItemsForUser:[userStore getAuthenticatedUser]];
	
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backWasTouched)];
	[[self navigationItem] setLeftBarButtonItem:button];
    [[self navigationItem] setTitle:@"User History"];
    
	self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:self.screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(self.screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
	[self.view addSubview:navBar];
    
    float topSectionHeight = 120;
    
    int imgWidth = 60;
    NSURL *url = [NSURL URLWithString:[[userStore getAuthenticatedUser] profileImageURL]];
    UIImageView *profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-imgWidth/2, frame.size.height+30, imgWidth, 70)];
    if ([[url absoluteString] isEqualToString:@""]) {
        TTLog(@"Searching for local image");
        NSString *imgURL = [[userStore getAuthenticatedUser] profileImageLocalURL];
        if (![imgURL isEqualToString:@""]){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
             {
                 TTLog(@"profile pic retrieved from %@", imgURL);
                 profilePicView.image = [UIImage imageWithCGImage:[asset thumbnail]];
             }
                    failureBlock:^(NSError *error )
             {
                 TTLog(@"Error loading asset");
             }];
        }
    } else {
        [profilePicView setImageWithURL:url
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    [self.view addSubview:profilePicView];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, frame.size.height+(topSectionHeight-30), frame.size.width, frame.size.height)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = [[userStore getAuthenticatedUser] name];
    [self.view addSubview:text];
    
    CGRect scrollFrame = CGRectMake(frame.size.width*.05, frame.size.height+topSectionHeight, frame.size.width*.9, self.screenFrame.size.height-frame.size.height-topSectionHeight);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
    UITableView *tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    [self.view addSubview:tableView];
    
    BottomNavViewController *navViewController = [[BottomNavViewController alloc] init];
    navViewController.navDelegate = self;
    [self addChildViewController:navViewController];
    [self.view addSubview:navViewController.view];
    navViewController.view.frame = CGRectMake(0, self.screenFrame.size.height-30, self.screenFrame.size.width, 50);
    [navViewController didMoveToParentViewController:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return self.userHistory.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    UITextView *dateView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    dateView.textAlignment = NSTextAlignmentLeft;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    dateView.text = [formatter stringFromDate:[[self.userHistory objectAtIndex:indexPath.row] date]];
    dateView.editable = NO;
    [container addSubview:dateView];
    
    for (int j = 0; j < 3; j++) {
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(40, j*20, frame.size.width, 20)];
        text.textAlignment = NSTextAlignmentLeft;
        NSString *thingString;
        TTLog(@"Things count: %d", [[[self.userHistory objectAtIndex:indexPath.row] things] count]);
        for (Thing *thing in [[self.userHistory objectAtIndex:indexPath.row] things]){
            TTLog(@"Thing: %@", thing);
            if([thing.index intValue] == j){
                thingString = thing.text;
                break;
            }
        }
        text.text = [NSString stringWithFormat:@"%d. %@", j+1, thingString];
        text.allowsEditingTextAttributes = NO;
        text.editable = NO;
        [container addSubview:text];
    }
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[self navigationController] pushViewController:
     [[My3ThingsViewController alloc] initWithShareDay:[TTShareDay shareDayWithShareObject:(ShareDay *)[self.userHistory objectAtIndex:indexPath.row]]
                                          andIsCurrent:[NSNumber numberWithBool:NO]]
      animated:YES];
}

- (void)backWasTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)reviewWasTouched {
    TTLog(@"User history screen got review callback");
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES]] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
