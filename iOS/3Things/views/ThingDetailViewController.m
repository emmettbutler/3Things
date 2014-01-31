//
//  ThingDetailViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ThingDetailViewController.h"
#import "TTNetManager.h"
#import "AppDelegate.h"
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
        commentWidth = 230;
        commentViewMargins = 8*2 + 10;
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.commentData = [[NSMutableDictionary alloc] init];
    self.commentData[@"data"] = [[NSMutableDictionary alloc] init];
    self.commentData[@"data"][@"comments"] = [[NSMutableArray alloc] init];
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
    self.picView = [[UIImageView alloc] initWithFrame:CGRectMake((self.screenFrame.size.width-IMG_DETAIL_SIZE)/2, 60, IMG_DETAIL_SIZE, IMG_DETAIL_SIZE)];
    [self.view addSubview:self.picView];
    if (![imgID isEqualToString:@""] && imgID != NULL){
        hasImage = YES;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [[TTNetManager sharedInstance] rootURL], imgID]];
        [self.picView setImageWithURL:url
                placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    CGSize textSize = [self.thing[@"text"] sizeWithFont:[UIFont fontWithName:HEADER_FONT size:13] constrainedToSize:CGSizeMake(commentWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.text = [[UITextView alloc] initWithFrame:CGRectMake(self.screenFrame.size.width*.05,
                                                             hasImage ? self.picView.frame.origin.y+self.picView.frame.size.height+10 : 60,
                                                             self.screenFrame.size.width*.9,
                                                             textSize.height+8*2)];
    self.text.textAlignment = NSTextAlignmentCenter;
    self.text.font = [UIFont fontWithName:HEADER_FONT size:13];
    self.text.editable = NO;
    [self.text setTextColor:[UIColor whiteColor]];
    self.text.text = self.thing[@"text"];
    self.text.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.text setUserInteractionEnabled:NO];
    [self.view addSubview:self.text];
    
    float fieldSizeMul = .9;
    CGRect newCommentFieldFrame = CGRectMake(self.screenFrame.size.width*((1-fieldSizeMul)/2),
                                             self.screenFrame.size.height-20,
                                             self.screenFrame.size.width*fieldSizeMul,
                                             30);
    self.commentField = [[UITextField alloc] initWithFrame:newCommentFieldFrame];
    self.commentField.placeholder = @"Comment...";
    self.commentField.delegate = self;
    self.commentField.font = [UIFont fontWithName:HEADER_FONT size:13];
    self.commentField.returnKeyType = UIReturnKeyGo;
    self.commentField.borderStyle = UITextBorderStyleRoundedRect;
    self.commentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.commentField];
    
    CGRect scrollFrame = CGRectMake(25,
                                    self.text.frame.origin.y+self.text.frame.size.height+10,
                                    self.screenFrame.size.width*.86,
                                    self.commentField.frame.origin.y-10-(self.text.frame.origin.y+self.text.frame.size.height));
    self.tableView = [[UITableView alloc] initWithFrame:scrollFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.userInteractionEnabled = YES;
    self.tableView.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
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
    UserStore *userStore = [[UserStore alloc] init];
    if (![textField.text isEqualToString:@""]) {
        TTLog(@"Field returned. Submitting comment.");
        [[TTNetManager sharedInstance] postCommentForThing:self.thing[@"index"]
                                                   withDay:self.thing[@"day_id"]
                                                   andUser:[userStore getAuthenticatedUser]
                                                   andText:textField.text];
        NSMutableDictionary *newComment = [[NSMutableDictionary alloc] init];
        newComment[@"day_id"] = self.thing[@"day_id"];
        newComment[@"index"] = self.thing[@"index"];
        newComment[@"text"] = textField.text;
        newComment[@"uid"] = [[userStore getAuthenticatedUser] userID];
        newComment[@"user"] = [[NSMutableDictionary alloc] init];
        User *user = [userStore getAuthenticatedUser];
        newComment[@"user"][@"_id"] = [user userID];
        newComment[@"user"][@"fbid"] = [user facebookID];
        newComment[@"user"][@"name"] = [user name];
        if ([user profileImageURL] != NULL) {
            newComment[@"user"][@"profileImageID"] = [user profileImageURL];
        }
        [self.commentData[@"data"][@"comments"] addObject:newComment];
        [self.tableView reloadData];
    }
    [self.commentField endEditing:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        //[[TTNetManager sharedInstance] getCommentsForThing:self.thing[@"index"] withDay:self.thing[@"day_id"]];
    });
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
    fieldFrame.origin.y = self.screenFrame.size.height-216-fieldFrame.size.height;
    self.commentField.frame = fieldFrame;
    fieldFrame = self.tableView.frame;
    int totalHeight = 0;
    for (int i = 0; i < [self.commentData[@"data"][@"comments"] count]; i++) {
        NSString *text = [self.commentData[@"data"][@"comments"] objectAtIndex:i][@"text"];
        CGSize size = [text sizeWithFont:[UIFont fontWithName:HEADER_FONT size:13] constrainedToSize:CGSizeMake(commentWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        totalHeight += size.height + commentViewMargins;
    }
    fieldFrame.size.height = MIN(totalHeight, self.screenFrame.size.height-216-self.commentField.frame.size.height-70);
    fieldFrame.origin.y = self.screenFrame.size.height-self.commentField.frame.size.height-216-10-fieldFrame.size.height;
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
    textField.text = @"Comment...";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentData[@"data"][@"comments"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.commentData[@"data"][@"comments"][indexPath.row][@"text"];
    CGSize size = [text sizeWithFont:[UIFont fontWithName:HEADER_FONT size:13] constrainedToSize:CGSizeMake(commentWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return size.height + commentViewMargins;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:MyIdentifier];
    }
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.commentData == nil) return cell;
    
    int imgWidth = 32;
    UITextView *commentText = [[UITextView alloc] initWithFrame:CGRectMake(imgWidth+8, 0, commentWidth, frame.size.height-10)];
    commentText.text = self.commentData[@"data"][@"comments"][indexPath.row][@"text"];
    CGSize size = [commentText.text sizeWithFont:[UIFont fontWithName:HEADER_FONT size:13] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    commentText.frame = CGRectMake(commentText.frame.origin.x, commentText.frame.origin.y, commentText.frame.size.width, size.height + 8*2);
    commentText.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    commentText.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    commentText.font = [UIFont fontWithName:HEADER_FONT size:13];
    [container addSubview:commentText];
    
    UIView *profilePicView;
    CGRect picFrame = CGRectMake(0, 0, imgWidth, imgWidth);
    NSString *fbid = self.commentData[@"data"][@"comments"][indexPath.row][@"user"][@"fbid"];
    NSString *profImgID = self.commentData[@"data"][@"comments"][indexPath.row][@"user"][@"_id"];
    if (fbid != NULL && ![fbid isEqualToString:@""]) {
        profilePicView = [[FBProfilePictureView alloc] initWithProfileID:fbid pictureCropping:FBProfilePictureCroppingSquare];
        profilePicView.frame = picFrame;
    } else {
        NSURL *url = [NSURL URLWithString:profImgID];
        profilePicView = [[UIImageView alloc] initWithFrame:picFrame];
        [(UIImageView *)profilePicView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/images/%@", [TTNetManager sharedInstance].rootURL, [url absoluteString]]]
                                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    CALayer *imageLayer = profilePicView.layer;
    [imageLayer setCornerRadius:profilePicView.frame.size.width/2];
    [imageLayer setMasksToBounds:YES];
    [cell addSubview:profilePicView];
    
    container.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    cell.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    
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
