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
#import "FriendFeedViewController.h"
#import "TTNetManager.h"

@implementation UserHistoryViewController

- (void)viewDidLoad
{
    TTLog(@"entered userhistory controller");
    [super viewDidLoad];
    
    self.feedData = nil;
    self.navigationController.navigationBarHidden = NO;
    
    ShareDayStore *store = [[ShareDayStore alloc] init];
    UserStore *userStore = [[UserStore alloc] init];
    self.user = [userStore getAuthenticatedUser];
    self.userHistory = [store allItemsForUser:self.user];
    
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getHistoryForUser:self.user.userID];
	
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    self.navigationItem.hidesBackButton = YES;
    [[self navigationItem] setTitle:@"USER HISTORY"];
    
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
    NSURL *url = [NSURL URLWithString:[self.user profileImageURL]];
    UIImageView *profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-imgWidth/2, frame.size.height+30, imgWidth, 70)];
    if (![[url absoluteString] isEqualToString:@""]) {
        TTLog(@"Searching for local image");
        NSString *imgURL = [self.user profileImageLocalURL];
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
    text.text = [self.user name];
    [self.view addSubview:text];
    
    CGRect scrollFrame = CGRectMake(frame.size.width*.05, frame.size.height+topSectionHeight, frame.size.width*.9, self.screenFrame.size.height-frame.size.height-topSectionHeight);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
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
    navViewController.view.frame = navViewController.frame;
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
        NSMutableArray *data = [[json objectForKey:@"data"] objectForKey:@"history"];
        
        self.feedData = [[NSMutableDictionary alloc] init];
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
        [formatter1 setDateFormat:@"MM"];
        [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
        
        for (int i = 0; i < [data count]; i++){
            NSDictionary *day = [data objectAtIndex:i];
            NSDate *date = [formatter2 dateFromString:[day objectForKey:@"date"]];
            NSString *monthString = [formatter1 stringFromDate:date];
            NSNumber *month = [NSNumber numberWithInt:[monthString intValue]];
            if ([self.feedData objectForKey:month] == nil) {
                [self.feedData setObject:[[NSMutableArray alloc] init] forKey:month];
            }
            [[self.feedData objectForKey:month] addObject:day];
        }
        
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.feedData == nil) return 1;
    TTLog(@"Feed month count: %d", [[self.feedData allKeys] count]);
    return [[self.feedData allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedData == nil) {
        return 2;
    } else {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
        NSArray *sortedKeys = [[self.feedData allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        NSNumber *thisMonth = [sortedKeys objectAtIndex:section];
        NSArray *monthDays = [self.feedData objectForKey:thisMonth];
        return [monthDays count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
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
    
    if (self.feedData == nil) return cell;
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedKeys = [[self.feedData allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSNumber *thisMonth = [sortedKeys objectAtIndex:indexPath.section];
    NSArray *monthDays = [self.feedData objectForKey:thisMonth];
    NSDictionary *day = [monthDays objectAtIndex:indexPath.row];
      
    UITextView *dateView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    dateView.textAlignment = NSTextAlignmentLeft;
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter2 dateFromString:[day objectForKey:@"date"]];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"MM/dd"];
    [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
    dateView.text = [formatter1 stringFromDate:date];
    dateView.editable = NO;
    [container addSubview:dateView];
    
    for (int j = 0; j < 3; j++) {
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(40, j*20, frame.size.width, 20)];
        text.textAlignment = NSTextAlignmentLeft;
        NSDictionary *thing = [[day objectForKey:@"things"] objectAtIndex:j];
        text.text = [NSString stringWithFormat:@"%d. %@", j+1, [thing objectForKey:@"text"]];
        text.allowsEditingTextAttributes = NO;
        text.editable = NO;
        [container addSubview:text];
    }
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *day = [[[self.feedData objectForKey:@"data"] objectForKey:@"history"] objectAtIndex:indexPath.row];
    [[self navigationController] pushViewController:
     [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] initWithSharesDictionary:day]
                                          andIsCurrent:[NSNumber numberWithBool:NO] andUser:self.user]
      animated:YES];
}

- (void)backWasTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)reviewWasTouched {
    TTLog(@"User history screen got review callback");
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:[NSNumber numberWithBool:YES] andUser:self.user] animated:YES];
}

- (void)friendsWasTouched {
    TTLog(@"User history screen got friends callback");
    [[self navigationController] pushViewController:[[FriendFeedViewController alloc] init] animated:YES];
}

-(void) calendarWasTouched {
    TTLog(@"Calendar requested on calendar screen. Do nothing???");
}

@end
