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
    
    NSString *imgURL = [self.thing objectForKey:@"localImageURL"];
    if (![imgURL isEqualToString:@""]){
        hasImage = YES;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
         {
             TTLog(@"thing image loaded successfully");
             UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, self.screenFrame.size.width, 300)];
             picView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
             [self.view addSubview:picView];
             [picView setUserInteractionEnabled:YES];
         }
                failureBlock:^(NSError *error )
         {
             TTLog(@"Error loading thing image");
         }];
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
