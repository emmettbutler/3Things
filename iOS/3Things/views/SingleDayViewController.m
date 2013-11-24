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
    return [self initWithShareDay:shares andIsCurrent:[NSNumber numberWithBool:NO] andUser:[userStore getAuthenticatedUser]];
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
        self.completedThings = [NSNumber numberWithInt:self.isCurrent ? 0 : 3];
        self.shares = shares;
        self.user = user;
        if (self.user == nil) {
            UserStore *userStore = [[UserStore alloc] init];
            self.user = [userStore getAuthenticatedUser];
        }
        TTLog(@"Entering single day view: %@", self.shares.theThings);
        TTLog(@"Time: %@", self.shares);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"000000" opacity:0];
    
    if (!self.isCurrent && !self.isEdited){
        ShareDayStore *dayStore = [[ShareDayStore alloc] init];
        if ([dayStore getToday] == NULL) {
            UserStore *userStore = [[UserStore alloc] init];
            [TTNetManager sharedInstance].netDelegate = self;
            [[TTNetManager sharedInstance] getTodayForUser:[userStore getAuthenticatedUser]];
        }
    }
    
    float width = .97;
    CGRect myFrame = CGRectMake(10, 70, 290, 420);
    CGRect scrollFrame = CGRectMake(10, 100, myFrame.size.width*width, myFrame.size.height-95);
    self.frame = myFrame;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, myFrame.size.width*width, 100)];
    bgView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"eff0f1"];
    [self.view addSubview:bgView];

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
    UITextView *dayOfWeekView = [[UITextView alloc] initWithFrame:CGRectMake(10, 3, 80, 30)];
    dayOfWeekView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayOfWeek = [dateFormatter stringFromDate:self.shares.time];
    dayOfWeekView.text = [dayOfWeek uppercaseString];
    dayOfWeekView.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE-2];
    dayOfWeekView.textColor = [[TTNetManager sharedInstance] colorWithHexString:HEADER_TEXT_COLOR];
    [topBarView addSubview:dayOfWeekView];
    UITextView *dayOfMonthView = [[UITextView alloc] initWithFrame:CGRectMake(175, 3, 100, 30)];
    dayOfMonthView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    dayOfMonthView.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE-2];
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
    NSURL *url = [NSURL URLWithString:[self.user profileImageURL]];
    UIImageView *profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(myFrame.size.width/2-imgWidth/2, 5, imgWidth, imgWidth)];
    if (![[url absoluteString] isEqualToString:@""] && url != NULL) {
        NSString *imgURL = [self.user profileImageLocalURL];
        if (![imgURL isEqualToString:@""] && imgURL != NULL){
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
             {
                 TTLog(@"Profile image loaded from %@", imgURL);
                 profilePicView.image = [UIImage imageWithCGImage:[asset thumbnail]];
             }
                    failureBlock:^(NSError *error )
             {
                 TTLog(@"Error loading profile image");
             }];
        }
    } else {
        [profilePicView setImageWithURL:url
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
    TTLog(@"In collectionView cellForItem");
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
    
    NSString *text = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"text"];
    if ([text isEqualToString:@""]) {
        text = @"Share something...";
    } else {
        self.completedThings = [NSNumber numberWithInt:[self.completedThings intValue] + 1];
        if([self.completedThings intValue] == 3) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UITextView *thingTextView = [[UITextView alloc] initWithFrame:CGRectMake(40, 15, frame.size.width*.6, 68)];
    int maxLen = 85;
    if ([text length] > maxLen) {
        text = [NSString stringWithFormat:@"%@...", [text substringToIndex:maxLen]];
    }
    [thingTextView setText:text];
    thingTextView.font = [UIFont fontWithName:HEADER_FONT size:THING_TEXT_SIZE];
    thingTextView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    thingTextView.textColor = [[TTNetManager sharedInstance] colorWithHexString:@"555555"];
    [container addSubview:thingTextView];
    
    int imgSize = 55;
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(210, 20, imgSize, imgSize)];
    CALayer *imageLayer = picView.layer;
    [imageLayer setCornerRadius:picView.frame.size.width/2];
    [imageLayer setMasksToBounds:YES];
    [container addSubview:picView];
    NSString *imgID = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"imageID"];
    NSString *imgURL = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"localImageURL"];
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
        self.feedData = json;
        self.shares = [[TTShareDay alloc] initWithSharesDictionary:[[[json objectForKey:@"data"] objectForKey:@"history"] objectAtIndex:0]];
        if ([self.parentViewController isKindOfClass:[My3ThingsViewController class]]){
            ((My3ThingsViewController *)self.parentViewController).shares = self.shares;
        }
        [self.collectionView reloadData];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (((ErrorThrowingViewController *)self.parentViewController).errViewIsShown) return;
    TTLog(@"Entering editor: %@", self.shares.theThings);
    if (self.isCurrent) {
        UIViewController *editView = [[EditThingViewController alloc] initWithThingIndex:[NSNumber numberWithInt:indexPath.row] andShares:self.shares];
        [[self navigationController] pushViewController:editView animated:YES];
    } else {
        ThingDetailViewController *detailView = [[ThingDetailViewController alloc] initWithThing:[self.shares.theThings objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:detailView animated:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch started in singleDay");
}

@end
