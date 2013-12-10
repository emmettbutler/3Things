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
    
    self.view.backgroundColor = [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1];
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect popupFrame = CGRectMake(0, (screenFrame.size.height/2-100/2), screenFrame.size.width, 100);
    self.frame = popupFrame;
    
    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, popupFrame.size.width, 60)];
    text.textAlignment = NSTextAlignmentCenter;
    text.text = [self.promptText uppercaseString];
    text.textColor = [UIColor whiteColor];
    text.font = [UIFont fontWithName:HEADER_FONT size:12];
    text.backgroundColor = self.view.backgroundColor;
    text.editable = NO;
    [self.view addSubview:text];
    
    UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reviewButton addTarget:self
                     action:@selector(okWasTouched)
           forControlEvents:UIControlEventTouchDown];
    [reviewButton setTitle:@"OK" forState:UIControlStateNormal];
    reviewButton.frame = CGRectMake(screenFrame.size.width/2-160/2, 30, 160, 50);
    reviewButton.backgroundColor = self.view.backgroundColor;
    reviewButton.titleLabel.font = [UIFont fontWithName:HEADER_FONT size:12];
    reviewButton.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:BUTTON_TEXT_BLUE_COLOR];
    reviewButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    [self.view addSubview:reviewButton];
    [reviewButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
}

- (void)okWasTouched{
    [self.errDelegate dismissWasTouched];
    [self.view removeFromSuperview];
}

@end
