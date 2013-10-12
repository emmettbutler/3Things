//
//  ShareErrorViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/12/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ShareErrorViewController.h"

@interface ShareErrorViewController ()

@end

@implementation ShareErrorViewController
@synthesize errDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, 50+(screenFrame.size.height/2), screenFrame.size.width, 100);
    self.frame = popupFrame;
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, popupFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = @"Enter your 3 things before sharing";
    text.textColor = [UIColor whiteColor];
    text.font = [UIFont systemFontOfSize:18];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
    
    UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reviewButton addTarget:self
                     action:@selector(okWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [reviewButton setTitle:@"Ok" forState:UIControlStateNormal];
    reviewButton.frame = CGRectMake(0, 30, popupFrame.size.width, 60);
    reviewButton.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:reviewButton];
}

- (void)okWasTouched{
    [self.errDelegate dismissWasTouched];
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
