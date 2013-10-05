//
//  EditThingViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "EditThingViewController.h"

@interface EditThingViewController ()

@end

@implementation EditThingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithThingIndex:(NSNumber *)thingIndex
{
    self = [super init];
    if (self) {
        self.thingIndex = thingIndex;
        NSLog(@"Thing index: %d", [self.thingIndex intValue]);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelWasTouched)];
	[[self navigationItem] setLeftBarButtonItem:button];
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"Share your %@ thing", [self getNumberWord]]];
    
	CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:screenFrame];
	CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(screenFrame.size.width, 60);
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
	[self.view addSubview:navBar];
    
    CGRect textFieldFrame = CGRectMake(screenFrame.size.width*.05, frame.size.height+50, screenFrame.size.width*.9, 120.0f);
    UITextView *textField = [[UITextView alloc] initWithFrame:textFieldFrame];
    textField.text = @"Share something";
    textField.textAlignment = NSTextAlignmentLeft;
    textField.editable = YES;
    textField.delegate = self;
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = [[UIColor grayColor] CGColor];
    textField.layer.cornerRadius = 10.0f;
    [textField becomeFirstResponder];
    [self.view addSubview:textField];
    
    UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imgButton addTarget:self
               action:@selector(imgButtonWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [imgButton setTitle:@"Photo" forState:UIControlStateNormal];
    imgButton.frame = CGRectMake(screenFrame.size.width*.05, textFieldFrame.origin.y+textFieldFrame.size.height+8, 50, 40.0);
    [self.view addSubview:imgButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton addTarget:self
                   action:@selector(nextWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(screenFrame.size.width*.55, textFieldFrame.origin.y+textFieldFrame.size.height+8, 50, 40.0);
    [self.view addSubview:saveButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nextButton addTarget:self
                  action:@selector(nextWasTouched)
        forControlEvents:UIControlEventTouchDown];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(screenFrame.size.width*.75, textFieldFrame.origin.y+textFieldFrame.size.height+8, 50, 40.0);
    [self.view addSubview:nextButton];
}

- (void)cancelWasTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)nextWasTouched {
    [[self navigationController] pushViewController:
     [[EditThingViewController alloc] initWithThingIndex:
      [NSNumber numberWithInt:self.thingIndex.intValue + 1]] animated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = @"";
}

- (NSString *)getNumberWord
{
    switch (self.thingIndex.intValue) {
        case 1:
            return @"first";
        case 2:
            return @"second";
        case 3:
            return @"third";
        default:
            return @"fifteenth";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
