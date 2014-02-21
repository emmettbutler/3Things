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

#define PUBLISHED_POSTS_SCREEN 0
#define UNPUBLISHED_POSTS_SCREEN 1
#define SORT_ASCENDING YES

@implementation UserHistoryViewController

- (void)viewDidLoad
{
    TTLog(@"entered userhistory controller");
    [super viewDidLoad];
    
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    
    self.feedData = nil;
    self.multipleYears = NO;
    
    ShareDayStore *store = [[ShareDayStore alloc] init];
    UserStore *userStore = [[UserStore alloc] init];
    self.user = [userStore getAuthenticatedUser];
    self.userHistory = [store allItemsForUser:self.user];
    
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getHistoryForUser:self.user.userID published:YES];
    
    self.navigationController.navigationBar.barTintColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    UIView *titleView = [[UIView alloc] init];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(-45, -15, 84, 28)];
    [logoView setImage:[UIImage imageNamed:@"Three_Things_logo.png"]];
    [titleView addSubview:logoView];
    self.navigationItem.titleView = titleView;
    
    self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(self.screenFrame.size.width, 60);
    
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
    
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"COMPLETED", @"MISSED"]];
    self.segmentControl.frame = CGRectMake(frame.size.width/2-100, frame.size.height+15, 200, 30);
    [self.segmentControl addTarget:self action:@selector(didSelectSegment) forControlEvents:UIControlEventValueChanged];
    self.segmentControl.selectedSegmentIndex = 0;
    self.segmentControl.tintColor = [[TTNetManager sharedInstance] colorWithHexString:@"326766"];
    UIFont *font = [UIFont fontWithName:HEADER_FONT size:13];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.segmentControl.layer.cornerRadius = 20;
    [self.view addSubview:self.segmentControl];
    
    CGRect scrollFrame = CGRectMake(0, frame.size.height+5+50, frame.size.width, self.screenFrame.size.height-frame.size.height-22-50);
    self.tableHeight = @(scrollFrame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    BottomNavViewController *navViewController = [[BottomNavViewController alloc] initWithScreen:kCalendarScreen];
    navViewController.navDelegate = self;
    [self addChildViewController:navViewController];
    [self.view addSubview:navViewController.view];
    navViewController.view.frame = navViewController.frame;
    [navViewController didMoveToParentViewController:self];
}

-(void)didSelectSegment {
    TTLog(@"Selected: %d", self.segmentControl.selectedSegmentIndex);
    [TTNetManager sharedInstance].netDelegate = self;
    if (self.segmentControl.selectedSegmentIndex == PUBLISHED_POSTS_SCREEN) {
        [[TTNetManager sharedInstance] getHistoryForUser:self.user.userID published:YES];
    } else if (self.segmentControl.selectedSegmentIndex == UNPUBLISHED_POSTS_SCREEN) {
        [[TTNetManager sharedInstance] getHistoryForUser:self.user.userID published:NO];
    }
    self.feedData = nil;
    [self.tableView reloadData];
}

-(void)dataWasReceived:(NSURLResponse *)res withData:(NSData *)data andError:(NSError *)error andOriginURL:(NSURL *)url
{
    TTLog(@"Error: %@", error);
    if (error == NULL) {
        TTLog(@"Data received: %@", url);
        UserStore *userStore = [[UserStore alloc] init];
        if ([[url absoluteString] rangeOfString:
             [NSString stringWithFormat:@"%@/users/%@/days", [TTNetManager sharedInstance].rootURL, [userStore getAuthenticatedUser].userID]].location == NSNotFound) {
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                              error:&jsonError];

        // please forgive me for the following
        if (json == NULL || [json[@"data"][@"history"] count] == 0) {
            [self.tableView reloadData];
            return;  // hack
        }
        NSMutableArray *history = json[@"data"][@"history"];
        
        self.feedData = [[NSMutableDictionary alloc] init];
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        // this formatter creates strings of the form yyyyMM (eg 201302 == February 2013)
        // this is a hack to force the sortedArrayUsingDescriptor method to sort the list of these
        // strings in what amounts to chronological order.
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
        [formatter1 setDateFormat:@"yyyyMM"];
        [formatter1 setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDate *startDate = [formatter2 dateFromString:history[0][@"date"]];
        
        TTLog(@"data: %@", json);
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *oneDay = [[NSDateComponents alloc] init];
        [oneDay setDay: 1];
        int i = 0;
        for (NSDate *date = startDate; [date compare:[NSDate date]] <= 0; date = [calendar dateByAddingComponents:oneDay toDate:date options:0] ) {
            NSMutableDictionary *day = nil;
            NSString *monthString = [formatter1 stringFromDate:date];
            NSDate *foundDate = [formatter2 dateFromString:history[i][@"date"]];
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
            NSDateComponents* comp1 = [calendar components:unitFlags fromDate:foundDate];
            NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
            BOOL hasDayForDate = [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year] == [comp2 year];
            if(hasDayForDate){
                day = history[i];
                if (self.feedData[monthString] == nil) {
                    [self.feedData setObject:[[NSMutableArray alloc] init] forKey:monthString];
                }
                [self.feedData[monthString] addObject:day];
                i = i < [history count] - 1 ? i + 1 : i;
            }
            if ([[url absoluteString] rangeOfString:@"published=0"].location != NSNotFound && !hasDayForDate) {  // unpublished
                // make a new empty day with date, put it in
                NSMutableDictionary *emptyDay = [[NSMutableDictionary alloc] init];
                emptyDay[@"date"] = [formatter2 stringFromDate:date];
                emptyDay[@"time"] = [formatter2 stringFromDate:date];
                emptyDay[@"published"] = @(0);
                emptyDay[@"things"] = [[NSMutableArray alloc] init];
                for (int j = 0; j < 3; j++) {
                    NSMutableDictionary *emptyThing = [[NSMutableDictionary alloc] init];
                    emptyThing[@"imageID"] = @"";
                    emptyThing[@"localImageURL"] = @"";
                    emptyThing[@"text"] = @"";
                    [emptyDay[@"things"] addObject:emptyThing];
                }
                [self.feedData[monthString] addObject:emptyDay];
            }
            NSTimeInterval interval = [date timeIntervalSinceDate:startDate];
            if (interval / 86400 >= 364) {  // check for a span of >1 year. this works since the list we receive here is sorted chronologically
                self.multipleYears = YES;
            }
        }
        
        [self.tableView reloadData];
    }
}

- (NSNumber *)getMonthNumberForSectionIndex:(NSInteger)section {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:SORT_ASCENDING];
    NSArray *sortedKeys = [[self.feedData allKeys] sortedArrayUsingDescriptors:@[sort]];
    return sortedKeys[section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.feedData == nil) return 1;
    return [[self.feedData allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedData == nil) {
        return 1;
    } else {
        NSNumber *thisMonth = [self getMonthNumberForSectionIndex:section];
        NSArray *monthDays = self.feedData[thisMonth];
        return [monthDays count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    
    if (self.feedData != nil) {
        NSNumber *thisMonth = [self getMonthNumberForSectionIndex:section];
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        // here, we extract the year and month from a six-digit number, where the 4 most significant digits are the year
        // and the two least significant digits are the month of that year
        int monthNumber = [thisMonth intValue] % 100;
        int yearNumber = ([thisMonth intValue] - monthNumber) / 100;
        NSString *monthName = [formatter2 monthSymbols][monthNumber - 1];
        if (self.multipleYears) {  // if the dates we received span more than a year, include years in the headers
            monthName = [monthName stringByAppendingString:[NSString stringWithFormat:@" %d", yearNumber]];
        }
        
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
        header.userInteractionEnabled = NO;
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.feedData == nil) {
        return 400;
    } else {
        return 100;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 100)];
    emptyView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    if(self.feedData != nil && [self.feedData count] == 0) {
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 100)];
        text.text = @"THERE ARE NO POSTS TO DISPLAY\nTOUCH BELOW TO POST";
        [emptyView addSubview:text];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont fontWithName:HEADER_FONT size:14];
        text.backgroundColor = emptyView.backgroundColor;
        text.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
        [container addSubview:emptyView];
    } else if (self.feedData == nil) {
        UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProgressWheel.png"]];
        spinner.frame = CGRectMake(emptyView.frame.size.width/2-100/2, 0, 100, 100);
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
        NSNumber *thisMonth = [self getMonthNumberForSectionIndex:indexPath.section];
        NSArray *monthDays = self.feedData[thisMonth];
        NSDictionary *day = monthDays[indexPath.row];
        
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
        [formatter2 setTimeZone:[NSTimeZone defaultTimeZone]];
        [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [formatter2 dateFromString:day[@"date"]];
        
        int width = 55;
        UIView *dateView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, frame.size.width, 20)];
        UITextView *dayOfMonthView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
        NSDateFormatter *dayOfMonthFormatter = [[NSDateFormatter alloc] init];
        [dayOfMonthFormatter setDateFormat:@"d"];
        [dayOfMonthFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        dayOfMonthView.text = [dayOfMonthFormatter stringFromDate:date];
        dayOfMonthView.font = [UIFont fontWithName:HEADER_FONT size:34];
        dayOfMonthView.textAlignment = NSTextAlignmentCenter;
        dayOfMonthView.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0];
        dayOfMonthView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
        dayOfMonthView.editable = NO;
        [dateView addSubview:dayOfMonthView];
        UITextView *dayOfWeekView = [[UITextView alloc] initWithFrame:CGRectMake(0, 50, width, 25)];
        dayOfWeekView.textAlignment = NSTextAlignmentLeft;
        NSDateFormatter *dayOfWeekFormatter = [[NSDateFormatter alloc] init];
        [dayOfWeekFormatter setDateFormat:@"ccc"];
        [dayOfWeekFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        dayOfWeekView.text = [[dayOfWeekFormatter stringFromDate:date] uppercaseString];
        dayOfWeekView.font = [UIFont fontWithName:HEADER_FONT size:13];
        dayOfWeekView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        dayOfWeekView.textAlignment = NSTextAlignmentCenter;
        dayOfWeekView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
        dayOfWeekView.editable = NO;
        [dateView addSubview:dayOfWeekView];
        [container addSubview:dateView];
        
        int images = 0;
        for (int j = 0; j < 3; j++){
            NSDictionary *thing = day[@"things"][j];
            NSString *imgID = thing[@"imageID"];
            if (![imgID isEqualToString:@""] && imgID != NULL){
                images++;
            }
        }
        int addedImages = 0;
        
        for (int j = 0; j < 3; j++) {
            UITextView *thingView = [[UITextView alloc] initWithFrame:CGRectMake(60, 10+(j*23), (images == 0) ? 240 : 155, 22)];
            
            UITextView *numberView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 22)];
            numberView.text = [NSString stringWithFormat:@"%d", j+1];
            numberView.editable = NO;
            numberView.font = [UIFont fontWithName:HEADER_FONT size:11];
            numberView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
            numberView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
            [thingView addSubview:numberView];
            
            NSDictionary *thing = day[@"things"][j];
            
            UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(12, 0, frame.size.width, 26)];
            text.textAlignment = NSTextAlignmentLeft;
            text.text = thing[@"text"];
            text.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
            text.allowsEditingTextAttributes = NO;
            text.font = [UIFont fontWithName:HEADER_FONT size:11];
            text.editable = NO;
            int maxWidth = images == 0 ? 200 : 140;
            CGSize size = [text.text sizeWithFont:text.font constrainedToSize:CGSizeMake(FLT_MAX, 40) lineBreakMode:NSLineBreakByWordWrapping];
            while (size.width > maxWidth) {
                text.text = [NSString stringWithFormat:@"%@...", [text.text substringToIndex:[text.text length]-4]];
                size = [text.text sizeWithFont:text.font constrainedToSize:CGSizeMake(FLT_MAX, 40) lineBreakMode:NSLineBreakByWordWrapping];
            }
            [thingView addSubview:text];
            
            [container addSubview:thingView];
            
            int picTop = 20, picLeft = 225, picHeight = 60, picWidthSmall = 60, picWidthTiny = 30;
            
            NSString *imgID = thing[@"imageID"];
            if (![imgID isEqualToString:@""] && imgID != NULL){
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
    }
    container.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isViewLoaded) return;
    
    NSNumber *thisMonth = [self getMonthNumberForSectionIndex:indexPath.section];
    NSArray *monthDays = self.feedData[thisMonth];
    NSDictionary *day = monthDays[indexPath.row];
    
    if (self.segmentControl.selectedSegmentIndex == PUBLISHED_POSTS_SCREEN) {
        [[self navigationController] pushViewController:
         [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] initWithSharesDictionary:day]
                                              andIsCurrent:@(NO) andUser:self.user]
                                               animated:YES];
    } else if (self.segmentControl.selectedSegmentIndex == UNPUBLISHED_POSTS_SCREEN) {
        [[self navigationController] pushViewController:
         [[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] initWithSharesDictionary:day]
                                              andIsCurrent:@(YES) andUser:self.user andIsEdited:@(YES)]
                                               animated:YES];
    }
}

- (void)backWasTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)reviewWasTouched {
    if (!self.isViewLoaded) return;
    TTLog(@"User history screen got review callback");
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] initWithShareDay:[[TTShareDay alloc] init] andIsCurrent:@(YES) andUser:self.user] animated:YES];
}

- (void)friendsWasTouched {
    if (!self.isViewLoaded) return;
    TTLog(@"User history screen got friends callback");
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
    [viewControllers removeLastObject];
    [viewControllers addObject:[[FriendFeedViewController alloc] init]];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

-(void) calendarWasTouched {
    TTLog(@"Calendar requested on calendar screen. Do nothing???");
}

-(void) didReceiveMemoryWarning {
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    [viewControllers addObject:self];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

@end
