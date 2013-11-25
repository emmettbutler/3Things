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
    
    UIView *titleView = [[UIView alloc] init];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(-65, -24, 120, 40)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [titleView addSubview:logoView];
    self.navigationItem.titleView = titleView;
    
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
    //[self.view addSubview:profilePicView];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, frame.size.height+(topSectionHeight-30), frame.size.width, frame.size.height)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = [self.user name];
    //[self.view addSubview:text];
    
    CGRect scrollFrame = CGRectMake(0, frame.size.height+5, frame.size.width, self.screenFrame.size.height-frame.size.height);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
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
    TTLog(@"Data received: %@", url);
    if (error == NULL) {
        UserStore *userStore = [[UserStore alloc] init];
        if (![[url absoluteString] isEqualToString:
              [NSString stringWithFormat:@"%@/users/%@/days", [TTNetManager sharedInstance].rootURL, [userStore getAuthenticatedUser].userID]]) {
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];
        TTLog(@"json response: %@", json);
        // please forgive me for the following
        if (json == NULL) return;  // hack
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
    if (self.feedData == nil) return 0;
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
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedKeys = [[self.feedData allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSNumber *thisMonth = [sortedKeys objectAtIndex:section];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    NSString *monthName = [[formatter2 monthSymbols] objectAtIndex:[thisMonth intValue] - 1];
    
    UITextView *monthNameView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.screenFrame.size.width, 23)];
    monthNameView.text = [monthName uppercaseString];
    monthNameView.editable = NO;
    monthNameView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    monthNameView.textAlignment = NSTextAlignmentCenter;
    monthNameView.font = [UIFont fontWithName:HEADER_FONT size:13];
    monthNameView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    [header addSubview:monthNameView];
    
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenFrame.size.width, 1)];
    bar.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    [header addSubview:bar];
    header.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter2 dateFromString:[day objectForKey:@"date"]];
    
    UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, frame.size.width, 20)];
    UITextView *dayOfMonthView = [[UITextView alloc] initWithFrame:CGRectMake(3, 0, 70, 90)];
    NSDateFormatter *dayOfMonthFormatter = [[NSDateFormatter alloc] init];
    [dayOfMonthFormatter setDateFormat:@"d"];
    [dayOfMonthFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    dayOfMonthView.text = [dayOfMonthFormatter stringFromDate:date];
    dayOfMonthView.font = [UIFont fontWithName:HEADER_FONT size:34];
    dayOfMonthView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    dayOfMonthView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    dayOfMonthView.editable = NO;
    [dateView addSubview:dayOfMonthView];
    UITextView *dayOfWeekView = [[UITextView alloc] initWithFrame:CGRectMake(8, 50, 40, 25)];
    dayOfWeekView.textAlignment = NSTextAlignmentLeft;
    NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc] init];
    [dayOfWeekFormatter setDateFormat:@"ccc"];
    [dayOfWeekFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    dayOfWeekView.text = [[dayOfWeekFormatter stringFromDate:date] uppercaseString];
    dayOfWeekView.font = [UIFont fontWithName:HEADER_FONT size:13];
    dayOfWeekView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    dayOfWeekView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    dayOfWeekView.editable = NO;
    [dateView addSubview:dayOfWeekView];
    [container addSubview:dateView];
    
    int images = 0;
    for (int j = 0; j < 3; j++){
        NSDictionary *thing = [[day objectForKey:@"things"] objectAtIndex:j];
        NSString *imgID = [thing objectForKey:@"imageID"];
        if (![imgID isEqualToString:@""] && imgID != NULL){
            images++;
        }
    }
    TTLog(@"Images: %d", images);
    int addedImages = 0;
    
    for (int j = 0; j < 3; j++) {
        UITextView *thingView = [[UITextView alloc] initWithFrame:CGRectMake(60, 10+(j*20), (images == 0) ? 240 : 155, 22)];
        
        UITextView *numberView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 22)];
        numberView.text = [NSString stringWithFormat:@"%d", j+1];
        numberView.editable = NO;
        numberView.font = [UIFont fontWithName:HEADER_FONT size:11];
        numberView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
        numberView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
        [thingView addSubview:numberView];
        
        NSDictionary *thing = [[day objectForKey:@"things"] objectAtIndex:j];
        
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(12, 0, frame.size.width, 26)];
        text.textAlignment = NSTextAlignmentLeft;
        text.text = [NSString stringWithFormat:@"%@", [thing objectForKey:@"text"]];
        text.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
        text.allowsEditingTextAttributes = NO;
        text.font = [UIFont fontWithName:HEADER_FONT size:11];
        text.editable = NO;
        int maxLen = images == 0 ? 48 : 30;
        if ([text.text length] > maxLen) {
            text.text = [NSString stringWithFormat:@"%@...", [text.text substringToIndex:maxLen]];
        }
        [thingView addSubview:text];
        
        [container addSubview:thingView];
        
        int picTop = 20, picLeft = 225, picHeight = 60, picWidthSmall = 60, picWidthTiny = 30;
        
        NSString *imgID = [thing objectForKey:@"imageID"];
        if (![imgID isEqualToString:@""] && imgID != NULL){
            TTLog(@"Added images: %d", addedImages);
            UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(picLeft, picTop, picWidthSmall, picHeight)];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [[TTNetManager sharedInstance] rootURL], imgID]];
            [picView setImageWithURL:url
                    placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            if (images == 1) {
                
            } else if(images == 2) {
                if (addedImages == 0) {
                    picView.frame = CGRectMake(picLeft, picTop, picWidthSmall, picWidthSmall);
                } else if (addedImages == 1) {
                    picView.frame = CGRectMake(picLeft+picWidthSmall+1, picTop, picWidthTiny, picWidthTiny);
                }
            } else if(images == 3) {
                if (j == 0) {
                    picView.frame = CGRectMake(picLeft, picTop, picWidthSmall, picWidthSmall);
                } else if (j == 1) {
                    picView.frame = CGRectMake(picLeft+picWidthSmall+1, picTop, picWidthTiny, picWidthTiny);
                } else if (j == 2) {
                    picView.frame = CGRectMake(picLeft+picWidthSmall+1, picTop+picWidthTiny, picWidthTiny, picWidthTiny);
                }
            }
            addedImages += 1;
            [container addSubview:picView];
        }
    }
    container.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedKeys = [[self.feedData allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    NSNumber *thisMonth = [sortedKeys objectAtIndex:indexPath.section];
    NSArray *monthDays = [self.feedData objectForKey:thisMonth];
    NSDictionary *day = [monthDays objectAtIndex:indexPath.row];
    
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
