//
//  SingleDayViewController.m
//  3Things
//
//  Created by Emmett Butler on 11/11/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "SingleDayViewController.h"
#import "UserStore.h"
#import "ShareDayStore.h"
#import "TTNetManager.h"
#import "AppDelegate.h"
#import "Thing.h"
#import "ThingDetailViewController.h"
#import "My3ThingsViewController.h"
#import "ErrorThrowingViewController.h"
#import "TTDate.h"
#import "EditThingViewController.h"

@interface SingleDayViewController ()

@end

@implementation SingleDayViewController

- (id)initWithIsCurrent:(NSNumber *)isCurrent {
    UserStore *userStore = [[UserStore alloc] init];
    return [self initWithShareDay:NULL andIsCurrent:isCurrent andUser:[userStore getAuthenticatedUser]];
}

- (id)initWithShareDay:(TTShareDay *)shares {
    UserStore *userStore = [[UserStore alloc] init];
    return [self initWithShareDay:shares andIsCurrent:@(NO) andUser:[userStore getAuthenticatedUser]];
}

- (id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user andIsEdited:(NSNumber *)isEdited {
    self = [self initWithShareDay:shares andIsCurrent:isCurrent andUser:user];
    self.isEdited = [isEdited boolValue];
    return self;
}

-(id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent andUser:(User *)user
{
    self = [super init];
    if (self) {
        self.isCurrent = [isCurrent boolValue];
        self.isEdited = NO;
        self.shares = shares;
        for (int i = 0; i < 3; i++) {
            if (![self.shares.theThings[i][@"text"] isEqualToString:@""]) {
                self.completedThings = @([self.completedThings intValue] + 1);
            }
        }
        self.user = user;
        if (self.user == nil) {
            TTLog(@"Getting authenticated user");
            UserStore *userStore = [[UserStore alloc] init];
            self.user = [userStore getAuthenticatedUser];
        } else {
            TTLog(@"User: %@", self.user);
        }
        TTLog(@"Entering single day view: %@", self.shares.theThings);
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sessionStateChanged:(NSNotification*)notification {
    TTLog(@"Facebook session changed, everything is broken");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification
     object:nil];
    */
     
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"000000" opacity:0];
    
    TTLog(@"current: %d, edited: %d", self.isCurrent, self.isEdited);
    if (!self.isCurrent && !self.isEdited){
        ShareDayStore *dayStore = [[ShareDayStore alloc] init];
        if ([dayStore getToday] == NULL) {
            UserStore *userStore = [[UserStore alloc] init];
            [TTNetManager sharedInstance].netDelegate = self;
            //[[TTNetManager sharedInstance] getTodayForUser:[userStore getAuthenticatedUser]];
        }
    }
    
    float width = .97;
    CGRect myFrame = CGRectMake(10, 70, 290, 420);
    CGRect scrollFrame = CGRectMake(10, 100, myFrame.size.width*width, myFrame.size.height-95);
    self.frame = myFrame;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(40, 0, myFrame.size.width*width, 100)];
    bgView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.view addSubview:bgView];
    
    UIView *innerBGView = [[UIView alloc] initWithFrame:CGRectMake(10, 30, myFrame.size.width*width, 100)];
    innerBGView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"eff0f1"];
    [self.view addSubview:innerBGView];

    UICollectionViewFlowLayout* flow = [[UICollectionViewFlowLayout alloc] init];
    CGRect collectionFrame = CGRectMake(0, 100, scrollFrame.size.width+20, scrollFrame.size.height-20);
    [flow setItemSize:CGSizeMake(collectionFrame.size.width-20, (collectionFrame.size.height)/3)];
    [flow setMinimumLineSpacing:1];
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:flow];
    self.collectionView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyReuseIdentifier"];
    [self.collectionView reloadData];
    [self.view addSubview:self.collectionView];
    
    CGRect headFrame = CGRectMake(10, 0, 0, 0);
    headFrame.size = CGSizeMake(myFrame.size.width*width, 60);
    
    UIView *topBarView = [[UIView alloc] initWithFrame:CGRectMake(10, 15, headFrame.size.width, 30)];
    topBarView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    UITextView *dayOfWeekView = [[UITextView alloc] initWithFrame:CGRectMake(0, 3, 80, 30)];
    dayOfWeekView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayOfWeek = [dateFormatter stringFromDate:self.shares.time];
    dayOfWeekView.text = [dayOfWeek uppercaseString];
    dayOfWeekView.textAlignment = NSTextAlignmentLeft;
    dayOfWeekView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    dayOfWeekView.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE-2];
    dayOfWeekView.textColor = [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR];
    [topBarView addSubview:dayOfWeekView];
    UITextView *dayOfMonthView = [[UITextView alloc] initWithFrame:CGRectMake(175, 3, 100, 30)];
    dayOfMonthView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    dayOfMonthView.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE-2];
    dayOfMonthView.textAlignment = NSTextAlignmentRight;
    dayOfMonthView.textColor = [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR];
    [dateFormatter setDateFormat:@"MMMM dd"];
    NSString *dayOfMonth = [dateFormatter stringFromDate:self.shares.time];
    dayOfMonthView.text = [NSString stringWithFormat:@"%@", [dayOfMonth uppercaseString]];
    [topBarView addSubview:dayOfMonthView];
    [self.view addSubview:topBarView];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 60, myFrame.size.width, 20)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = [[self.user name] uppercaseString];
    text.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    text.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE];
    text.editable = NO;
    [self.view addSubview:text];
    
    if (!self.isCurrent){
        UITextView *timeAgo = [[UITextView alloc] initWithFrame:CGRectMake(0, 80, self.frame.size.width, 30)];
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[self.shares.time timeIntervalSince1970]];
        timeAgo.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        timeAgo.font = [UIFont fontWithName:SCRIPT_FONT size:11];
        timeAgo.textAlignment = NSTextAlignmentCenter;
        timeAgo.text = [NSString stringWithFormat:@"%@ ago", [date timeAgo]];
        timeAgo.textColor = [[TTNetManager sharedInstance] colorWithHexString:@"444444"];
        [self.view addSubview:timeAgo];
    }
    
    int imgWidth = 55;
    
    UIView *profilePicView;
    CGRect picFrame = CGRectMake(myFrame.size.width/2-imgWidth/2, 5, imgWidth, imgWidth);
    TTLog(@"user facebook ID: %@", [self.user facebookID]);
    if ([self.user facebookID] != NULL && ![[self.user facebookID] isEqualToString:@""]) {
        profilePicView = [[FBProfilePictureView alloc] initWithProfileID:[self.user facebookID] pictureCropping:FBProfilePictureCroppingSquare];
        profilePicView.frame = picFrame;
    } else {
        NSURL *url = [NSURL URLWithString:[self.user profileImageURL]];
        profilePicView = [[UIImageView alloc] initWithFrame:picFrame];
        [(UIImageView *)profilePicView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [TTNetManager sharedInstance].rootURL, [url absoluteString]]]
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    CALayer *imageLayer = profilePicView.layer;
    [imageLayer setCornerRadius:profilePicView.frame.size.width/2];
    [imageLayer setMasksToBounds:YES];
    [self.view addSubview:profilePicView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MyIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    container.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"eff0f1"];
    
    UIImageView *flagView = [[UIImageView alloc] initWithFrame:CGRectMake(-6, 20, 40, 40)];
    NSString *image = @"";
    switch ([indexPath row]){
        case 0:
            image = @"Flag_1.png";
            break;
        case 1:
            image = @"Flag_2.png";
            break;
        case 2:
            image = @"Flag_3.png";
            break;
        default:
            image = @"HUGE ERROR";
            break;
    }
    [flagView setImage:[UIImage imageNamed:image]];
    [container addSubview:flagView];
    
    NSString *text = self.shares.theThings[indexPath.row][@"text"];
    if ([text isEqualToString:@""]) {
        text = @"Share something...";
    }
    UITextView *thingTextView = [[UITextView alloc] initWithFrame:CGRectMake(40, 5, frame.size.width*.6, 75)];
    [thingTextView setText:text];
    int maxHeight = thingTextView.frame.size.height - 20;
    CGSize size = [thingTextView.text sizeWithFont:thingTextView.font constrainedToSize:CGSizeMake(thingTextView.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    while (size.height > maxHeight) {
        thingTextView.text = [NSString stringWithFormat:@"%@...", [thingTextView.text substringToIndex:[thingTextView.text length]-4]];
        size = [thingTextView.text sizeWithFont:thingTextView.font constrainedToSize:CGSizeMake(thingTextView.frame.size.width, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    }
    thingTextView.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE];
    thingTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    thingTextView.textColor = [[TTNetManager sharedInstance] colorWithHexString:@"555555"];
    [container addSubview:thingTextView];
    
    if (!self.isCurrent) {
        UITextView *commentCountView = [[UITextView alloc] initWithFrame:CGRectMake(40, 70, 100, 30)];
        commentCountView.font = [UIFont fontWithName:SCRIPT_FONT size:13];
        commentCountView.userInteractionEnabled = NO;
        commentCountView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        int count = [self.shares.commentCount[indexPath.row] intValue];
        commentCountView.text = [NSString stringWithFormat:@"%d comment%@", count, count == 1 ? @"" : @"s"];
        commentCountView.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
        [container addSubview:commentCountView];
    }
    
    int imgSize = 55;
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(210, 20, imgSize, imgSize)];
    CALayer *imageLayer = picView.layer;
    [imageLayer setCornerRadius:picView.frame.size.width/2];
    [imageLayer setMasksToBounds:YES];
    [container addSubview:picView];
    NSString *imgID = self.shares.theThings[indexPath.row][@"imageID"];
    NSString *imgURL = self.shares.theThings[indexPath.row][@"localImageURL"];
    if (![imgID isEqualToString:@""] && imgID != NULL){
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [[TTNetManager sharedInstance] rootURL], imgID]];
        [picView setImageWithURL:url
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    } else if (![imgURL isEqualToString:@""] && imgURL != NULL){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
        {
            TTLog(@"thing image loaded at index %d", indexPath.row);
            picView.image = [UIImage imageWithCGImage:[asset thumbnail]];
        }
         failureBlock:^(NSError *error )
        {
            TTLog(@"Error loading thing image at index %d", indexPath.row);
        }];
    }
    cell.backgroundView = container;
    return cell;
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
        if (json == NULL) return;
        self.feedData = json;
        self.shares = [[TTShareDay alloc] initWithSharesDictionary:json[@"data"][@"history"][0]];
        if ([self.parentViewController isKindOfClass:[My3ThingsViewController class]]){
            ((My3ThingsViewController *)self.parentViewController).shares = self.shares;
        }
        [self.collectionView reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isViewLoaded) return;
    if (((ErrorThrowingViewController *)self.parentViewController).errViewIsShown) return;
    if (self.isCurrent) {
        UIViewController *editView = [[EditThingViewController alloc] initWithThingIndex:@(indexPath.row) andShares:self.shares];
        [[self navigationController] pushViewController:editView animated:YES];
    } else {
        NSMutableDictionary *thing = [NSMutableDictionary dictionaryWithDictionary:self.shares.theThings[indexPath.row]];
        thing[@"index"] = @(indexPath.row);
        thing[@"day_id"] = self.shares._id;
        ThingDetailViewController *detailView = [[ThingDetailViewController alloc] initWithThing:thing];
        [[self navigationController] pushViewController:detailView animated:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch started in singleDay");
}

@end
