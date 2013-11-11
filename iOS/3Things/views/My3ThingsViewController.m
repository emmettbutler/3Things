//
//  My3ThingsViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "My3ThingsViewController.h"
#import "EditThingViewController.h"
#import "TTShareDay.h"
#import "ShareDayStore.h"
#import "UserHistoryViewController.h"
#import "UserStore.h"
#import "ThingDetailViewController.h"
#import "ErrorPromptViewController.h"
#import "TTNetManager.h"
#import "Thing.h"

@interface My3ThingsViewController ()

@end

@implementation My3ThingsViewController

- (id)initWithIsCurrent:(NSNumber *)isCurrent {
    return [self initWithShareDay:NULL andIsCurrent:isCurrent];
}

- (id)initWithShareDay:(TTShareDay *)shares {
    return [self initWithShareDay:shares andIsCurrent:[NSNumber numberWithBool:NO]];
}

-(id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent
{
    self = [super init];
    if (self) {
        self.isCurrent = [isCurrent boolValue];
        self.completedThings = [NSNumber numberWithInt:self.isCurrent ? 0 : 3];
        
        ShareDayStore *itemStore = [[ShareDayStore alloc] init];
        ShareDay *today = [itemStore getToday];
        if (!self.isCurrent) {
            TTLog(@"Got sent a day in the past");
            self.shares = shares;
        } else if (today == NULL) {
            TTLog(@"Found nothing");
            self.shares = [[TTShareDay alloc] init];
        } else {
            TTLog(@"Found an entry");
            for (Thing *thing in today.things){
                TTLog(@"%@", thing.text);
            }
            self.shares = [TTShareDay shareDayWithShareObject:today];
        }
        TTLog(@"Entering 3things view: %@", self.shares.theThings);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accessor = [[TTSharesAccessor alloc] init];
    
    UserStore *userStore = [[UserStore alloc] init];
	
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];

    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backWasTouched)];
	[[self navigationItem] setLeftBarButtonItem:button];
    if (self.isCurrent) {
        [[self navigationItem] setTitle:@"Review your three things"];
    }
    
	self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:self.screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(self.screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
	[self.view addSubview:navBar];
    
    float mainButtonHeight = 65;
    
    CGRect scrollFrame = CGRectMake(frame.size.width*.05, frame.size.height+mainButtonHeight, frame.size.width*.9, self.screenFrame.size.height-frame.size.height-mainButtonHeight-50);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
    UITableView *tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    if (self.isCurrent){
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [shareButton addTarget:self
                        action:@selector(shareWasTouched)
              forControlEvents:UIControlEventTouchDown];
        [shareButton setTitle:@"Share" forState:UIControlStateNormal];
        shareButton.frame = CGRectMake(80.0, self.screenFrame.size.height-40, 160.0, 40.0);
        [self.view addSubview:shareButton];
    }
    
    [self.view addSubview:tableView];
    
    int imgWidth = 40;
    NSURL *url = [NSURL URLWithString:[[userStore getAuthenticatedUser] profileImageURL]];
    UIImageView *profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-imgWidth/2, frame.size.height+25, imgWidth, 50)];
    if (![[url absoluteString] isEqualToString:@""]) {
        NSString *imgURL = [[userStore getAuthenticatedUser] profileImageLocalURL];
        if (![imgURL isEqualToString:@""]){
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
    [self.view addSubview:profilePicView];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [[UITableViewHeaderFooterView alloc] init];
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(self.screenFrame.size.width*.9, 60);
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    text.textAlignment = NSTextAlignmentCenter;
    UserStore *userStore = [[UserStore alloc] init];
    text.text = [[userStore getAuthenticatedUser] name];
    [header addSubview:text];
    
    UITextView *text2 = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 23)];
    text2.textAlignment = NSTextAlignmentCenter;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    text2.text = [formatter stringFromDate:self.shares.date];
    [header addSubview:text2];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.tableHeight.floatValue-44)/3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    NSString *text = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"text"];
    if ([text isEqualToString:@""]) {
        text = @"Share something...";
    } else {
        self.completedThings = [NSNumber numberWithInt:[self.completedThings intValue] + 1];
        TTLog(@"Counted completed thing for day: %d", [self.completedThings intValue]);
        if([self.completedThings intValue] == 3) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UITextView *thingTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    [thingTextView setText:text];
    [thingTextView setFont:[UIFont systemFontOfSize:20]];
    [container addSubview:thingTextView];
    
    NSString *imgURL = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"localImageURL"];
    if (![imgURL isEqualToString:@""]){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
         {
             TTLog(@"thing image loaded at index %d", indexPath.row);
             UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 0, 40, 40)];
             picView.image = [UIImage imageWithCGImage:[asset thumbnail]];
             [container addSubview:picView];
         }
        failureBlock:^(NSError *error )
         {
             TTLog(@"Error loading thing image at index %d", indexPath.row);
         }];
    }
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.errViewIsShown) return;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTLog(@"Entering editor: %@", self.shares.theThings);
    if (self.isCurrent) {
        UIViewController *editView = [[EditThingViewController alloc] initWithThingIndex:[NSNumber numberWithInt:indexPath.row] andShares:self.shares];
        [[self navigationController] pushViewController:editView animated:YES];
    } else {
        ThingDetailViewController *detailView = [[ThingDetailViewController alloc] initWithThing:[self.shares.theThings objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:detailView animated:YES];
    }
}

- (void)backWasTouched {
    if (!self.errViewIsShown){
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)shareWasTouched {
    UserStore *userStore = [[UserStore alloc] init];
    if ([self.completedThings intValue] == 3) {
        [TTNetManager sharedInstance].netDelegate = (id<TTNetManagerDelegate>)self;
        [[TTNetManager sharedInstance] postShareDay:self.shares forUser:[[userStore getAuthenticatedUser] userID]];
        [[self navigationController] pushViewController:
         [[UserHistoryViewController alloc] init] animated:YES];
    } else {
        if (!self.errViewIsShown){
            self.errViewIsShown = YES;
            TTLog(@"Error: 3 things not completed for the day. Must complete 3 things before sharing.");
            ErrorPromptViewController *errViewController = [[ErrorPromptViewController alloc] initWithPromptText:@"Enter your 3 things before sharing"];
            [self addChildViewController:errViewController];
            [self.view addSubview:errViewController.view];
            errViewController.errDelegate = self;
            errViewController.view.frame = errViewController.frame;
            [errViewController didMoveToParentViewController:self];
        }
    }
}

- (BOOL)hasEnteredAllThings {
    if (self.shares.theThings.count == 0) return NO;
    for (int i = 0; i < 3; i++){
        if ([self.shares.theThings objectAtIndex:i] == NULL) {
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
