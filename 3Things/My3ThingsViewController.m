//
//  My3ThingsViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "My3ThingsViewController.h"
#import "EditThingViewController.h"

@interface My3ThingsViewController ()

@end

@implementation My3ThingsViewController

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
	
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backWasTouched)];
	[[self navigationItem] setLeftBarButtonItem:button];
    
	CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
	[self.view addSubview:navBar];
    
    float mainButtonHeight = 120;
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, frame.size.height+mainButtonHeight/2, frame.size.width, frame.size.height)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"User Photo Here";
    [self.view addSubview:text];
    
    CGRect scrollFrame = CGRectMake(0, frame.size.height+mainButtonHeight, frame.size.width, screenFrame.size.height-frame.size.height-mainButtonHeight);
    self.tableHeight = [NSNumber numberWithFloat:scrollFrame.size.height];
    UITableView *tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    [self.view addSubview:tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    return 3;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return @"My Things";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableHeight.floatValue/3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Thing %d", indexPath.row];
    // add images for friends
    //[cell addSubview:[[UIImageView alloc] initWithImage: ]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *editView = [[EditThingViewController alloc] init];
    [[self navigationController] pushViewController:editView animated:YES];
}

- (void)backWasTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
