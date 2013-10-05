//
//  UserHistoryViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "UserHistoryViewController.h"
#import "My3ThingsViewController.h"

@implementation UserHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accessor = [[TTSharesAccessor alloc] init];
	
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
    UIImageView *profilePicView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-imgWidth/2, frame.size.height+30, imgWidth, 70)];
    profilePicView.image = [UIImage imageNamed:@"prof_pic.jpg"];
    [self.view addSubview:profilePicView];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, frame.size.height+(topSectionHeight-30), frame.size.width, frame.size.height)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"Heather Smith";
    [self.view addSubview:text];
    
    CGRect scrollFrame = CGRectMake(frame.size.width*.05, frame.size.height+topSectionHeight, frame.size.width*.9, self.screenFrame.size.height-frame.size.height-topSectionHeight-80);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
    UITableView *tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self
                    action:@selector(shareWasTouched)
          forControlEvents:UIControlEventTouchDown];
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(80.0, self.screenFrame.size.height-50, 160.0, 40.0);
    [self.view addSubview:shareButton];
    
    [self.view addSubview:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return 3;
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
    return self.tableHeight.floatValue/3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    TTShareDay *shares = [self.accessor getFriendSharesForDate:NULL andUserName:@"heather"];
    for (int i = 0; i < 3; i++) {
        UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, i*20, frame.size.width, 20)];
        text.textAlignment = NSTextAlignmentLeft;
        text.text = [NSString stringWithFormat:@"%d. %@", i+1, [[shares.theThings objectAtIndex:i] text]];
        text.allowsEditingTextAttributes = NO;
        text.editable = NO;
        [container addSubview:text];
    }
    cell.backgroundView = container;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[self navigationController] pushViewController:[[My3ThingsViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
