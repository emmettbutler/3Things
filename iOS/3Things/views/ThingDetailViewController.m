//
//  ThingDetailViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ThingDetailViewController.h"
#import "TTNetManager.h"
#import "UserStore.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ThingDetailViewController ()

@end

@implementation ThingDetailViewController

- (id)initWithThing:(NSDictionary *)inThing
{
    if (self = [super init]) {
        self.thing = inThing;
        commentHeight = 40;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.commentData = nil;
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] getCommentsForThing:self.thing[@"index"] withDay:self.thing[@"day_id"]];
    
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
    self.picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, self.screenFrame.size.width, 300)];
    [self.view addSubview:self.picView];
    if (![imgID isEqualToString:@""] && imgID != NULL){
        hasImage = YES;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [[TTNetManager sharedInstance] rootURL], imgID]];
        [self.picView setImageWithURL:url
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    self.text = [[UITextView alloc] initWithFrame:CGRectMake(self.screenFrame.size.width*.05, hasImage ? 370 : 60, self.screenFrame.size.width*.9, 30+30*([self.thing[@"test"] count] % 80))];
    self.text.textAlignment = NSTextAlignmentCenter;
    self.text.font = [UIFont fontWithName:HEADER_FONT size:13];
    self.text.editable = NO;
    [self.text setTextColor:[UIColor whiteColor]];
    self.text.text = self.thing[@"text"];
    self.text.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.text setUserInteractionEnabled:NO];
    [self.view addSubview:self.text];
    
    CGRect scrollFrame = CGRectMake(0, self.text.frame.origin.y+self.text.frame.size.height+10, self.screenFrame.size.width, hasImage ? 95 : 200);
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    float fieldSizeMul = .9;
    CGRect newCommentFieldFrame = CGRectMake(self.screenFrame.size.width*((1-fieldSizeMul)/2), self.tableView.frame.origin.y+self.tableView.frame.size.height+10, self.screenFrame.size.width*fieldSizeMul, 40);
    self.commentField = [[UITextField alloc] initWithFrame:newCommentFieldFrame];
    self.commentField.placeholder = @"COMMENT...";
    self.commentField.delegate = self;
    self.commentField.returnKeyType = UIReturnKeyGo;
    self.commentField.borderStyle = UITextBorderStyleRoundedRect;
    self.commentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.commentField];
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
        if (json[@"data"][@"comments"] == nil) {
            return;
        }
        self.commentData = json;
        [self.tableView reloadData];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![textField.text isEqualToString:@""]) {
        UserStore *userStore = [[UserStore alloc] init];
        TTLog(@"Field returned. Submitting comment.");
        [[TTNetManager sharedInstance] postCommentForThing:self.thing[@"index"]
                                                   withDay:self.thing[@"day_id"]
                                                   andUser:[userStore getAuthenticatedUser]
                                                   andText:textField.text];
    }
    [self.commentField endEditing:YES];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    textFieldOriginalY = self.commentField.frame.origin.y;
    pastCommentsOriginalY = self.tableView.frame.origin.y;
    pastCommentsOriginalHeight = self.tableView.frame.size.height;
    self.picView.hidden = YES;
    self.text.hidden = YES;
    CGRect fieldFrame = self.commentField.frame;
    fieldFrame.origin.y = 300;
    self.commentField.frame = fieldFrame;
    fieldFrame = self.tableView.frame;
    fieldFrame.size.height = commentHeight*[self.commentData[@"data"][@"comments"] count];
    fieldFrame.origin.y = 300-10-fieldFrame.size.height;
    self.tableView.frame = fieldFrame;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    self.picView.hidden = NO;
    self.text.hidden = NO;
    CGRect fieldFrame = self.commentField.frame;
    fieldFrame.origin.y = textFieldOriginalY;
    self.commentField.frame = fieldFrame;
    fieldFrame = self.tableView.frame;
    fieldFrame.origin.y = pastCommentsOriginalY;
    fieldFrame.size.height = pastCommentsOriginalHeight;
    self.tableView.frame = fieldFrame;
    textField.text = @"COMMENT...";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentData[@"data"][@"comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return commentHeight;
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
    
    UITextView *commentText = [[UITextView alloc] initWithFrame:frame];
    commentText.text = self.commentData[@"data"][@"comments"][indexPath.row][@"text"];
    commentText.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    [container addSubview:commentText];
    
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
