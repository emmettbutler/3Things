//
//  ThingDetailViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ThingDetailViewController.h"
#import "TTNetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ThingDetailViewController ()

@end

@implementation ThingDetailViewController

- (id)initWithThing:(NSDictionary *)inThing
{
    if (self = [super init]) {
        self.thing = inThing;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.commentData = nil;
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getCommentsForThing:@(2) withDay:@"test"];
    
    self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"000000"];
    
    BOOL hasImage = NO;
    
    int closeButtonSize = 30, closeButtonMargin = 5;
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton addTarget:self action:@selector(closeWasTouched) forControlEvents:UIControlEventTouchDown];
    closeButton.frame = CGRectMake(self.screenFrame.size.width-closeButtonSize-closeButtonMargin, closeButtonMargin+20, closeButtonSize, closeButtonSize);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
    
    NSString *imgID = self.thing[@"imageID"];
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, self.screenFrame.size.width, 300)];
    [self.view addSubview:picView];
    if (![imgID isEqualToString:@""] && imgID != NULL){
        hasImage = YES;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [[TTNetManager sharedInstance] rootURL], imgID]];
        [picView setImageWithURL:url
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(self.screenFrame.size.width*.05, hasImage ? 370 : 60, self.screenFrame.size.width*.9, 100)];
    text.textAlignment = NSTextAlignmentCenter;
    text.font = [UIFont fontWithName:HEADER_FONT size:13];
    text.editable = NO;
    [text setTextColor:[UIColor whiteColor]];
    text.text = self.thing[@"text"];
    text.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.view addSubview:text];
    
    CGRect scrollFrame = CGRectMake(0, text.frame.origin.y+text.frame.size.height+10, self.screenFrame.size.width, hasImage ? 200 : 200);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];

    [text setUserInteractionEnabled:YES];
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
        self.commentData = json;
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    if (self.commentData == nil) return cell;
    
    cell.backgroundView = container;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [[UIView alloc] init];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTLog(@"Row was selected and NOTHING HAPPENED");
}

- (void)closeWasTouched {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
