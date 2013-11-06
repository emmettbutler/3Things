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
    
    BOOL hasImage = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    NSString *imgURL = [self.thing objectForKey:@"localImageURL"];
    if (![imgURL isEqualToString:@""]){
        hasImage = YES;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
         {
             TTLog(@"thing image loaded successfully");
             UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, self.screenFrame.size.width, 300)];
             picView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
             [self.view addSubview:picView];
             
             [picView addGestureRecognizer:singleTap];
             [picView setUserInteractionEnabled:YES];
         }
                failureBlock:^(NSError *error )
         {
             TTLog(@"Error loading thing image");
         }];
    }
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, hasImage ? 320 : 30, self.screenFrame.size.width, 80)];
    text.textAlignment = NSTextAlignmentCenter;
    text.font = [UIFont systemFontOfSize:18];
    text.editable = NO;
    text.text = [self.thing objectForKey:@"text"];
    [text setTextColor:[UIColor whiteColor]];
    [text setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:text];

    [text addGestureRecognizer:singleTap];
    [text setUserInteractionEnabled:YES];
}

- (void)imageTapped:(UIGestureRecognizer *)gestureRecognizer {
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
