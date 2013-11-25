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
	
    self.screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_LIGHT_GRAY];
    
    BOOL hasImage = NO;
    
    int closeButtonSize = 20, closeButtonMargin = 5;
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeButton addTarget:self action:@selector(closeWasTouched) forControlEvents:UIControlEventTouchDown];
    closeButton.frame = CGRectMake(self.screenFrame.size.width-closeButtonSize-closeButtonMargin, closeButtonMargin+20, closeButtonSize, closeButtonSize);
    [closeButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
    
    NSString *imgID = [self.thing objectForKey:@"imageID"];
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
    text.font = [UIFont fontWithName:HEADER_FONT size:11];
    text.editable = NO;
    [text setTextColor:[UIColor blackColor]];
    text.text = [self.thing objectForKey:@"text"];
    TTLog(@"thing text: %@", [self.thing objectForKey:@"text"]);
    text.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"FF0000" opacity:0];
    [self.view addSubview:text];

    [text setUserInteractionEnabled:YES];
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
