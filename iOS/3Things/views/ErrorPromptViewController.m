//
//  ErrorPromptViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/12/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ErrorPromptViewController.h"
#import "TTNetManager.h"

@interface ErrorPromptViewController ()

@end

@implementation ErrorPromptViewController
@synthesize errDelegate;

- (id)initWithPromptText:(NSString *)promptText {
    if (self = [super init]){
        self.promptText = promptText;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.parentViewController navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    int popupHeight = 110;
    float popupSizeFraction = .75;
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    CGRect popupFrame = CGRectMake(screenFrame.size.width*((1-popupSizeFraction)/2), (screenFrame.size.height/2-popupHeight/2), screenFrame.size.width*popupSizeFraction, popupHeight);
    self.frame = popupFrame;
    
    smoke = [[UIView alloc] initWithFrame:screenFrame];
    smoke.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
    [self.parentViewController.view addSubview:smoke];
    
    UITextView *oopsText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, popupFrame.size.width, 60)];
    oopsText.textAlignment = NSTextAlignmentCenter;
    oopsText.text = @"OOPS...";
    oopsText.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    oopsText.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    oopsText.font = [UIFont fontWithName:HEADER_FONT size:17];
    oopsText.backgroundColor = self.view.backgroundColor;
    oopsText.editable = NO;
    [self.view addSubview:oopsText];
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 30, popupFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = [self.promptText uppercaseString];
    text.textColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    text.font = [UIFont fontWithName:HEADER_FONT size:12];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, popupFrame.size.height-40-1, popupFrame.size.width, 2)];
    line.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"BBBBBB"];
    [self.view addSubview:line];
    
    UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reviewButton addTarget:self
                     action:@selector(okWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [reviewButton setTitle:@"OK" forState:UIControlStateNormal];
    reviewButton.frame = CGRectMake(0, popupFrame.size.height-40, popupFrame.size.width, 40);
    reviewButton.backgroundColor = self.view.backgroundColor;
    reviewButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    reviewButton.backgroundColor = [UIColor whiteColor];
    reviewButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [self.view addSubview:reviewButton];
    [reviewButton setTitleColor:[[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR] forState:UIControlStateNormal];
}

- (void)okWasTouched{
    [self.errDelegate dismissWasTouched];
    [smoke removeFromSuperview];
    [[self.parentViewController navigationController] setNavigationBarHidden:NO animated:NO];
    [self.view removeFromSuperview];
}

@end
