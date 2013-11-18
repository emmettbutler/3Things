//
//  EditThingViewController.m
//  3Things
//
//  Created by Emmett Butler on 9/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "EditThingViewController.h"
#import "UserHistoryViewController.h"
#import "My3ThingsViewController.h"
#import "ThingStore.h"
#import "ShareDayStore.h"
#import "UserStore.h"
#import "PhotoPromptViewController.h"
#import "BackgroundLayer.h"

@interface EditThingViewController ()

@end

@implementation EditThingViewController

- (id)initWithThingIndex:(NSNumber *)thingIndex andShares:(TTShareDay *)shares
{
    self = [super init];
    if (self) {
        // TODO - thing detail view versus thing edit view - when to go to each?
        self.shares = shares;
        self.thingIndex = thingIndex;
        self.firstEdit = YES;
        self.thingText = @"Share something...";
        self.photoPromptIsHidden = NO;
        NSString *text;
        if (![[[self.shares.theThings objectAtIndex:[thingIndex intValue]] objectForKey:@"text"] isEqualToString:@""]){
            text = [[shares.theThings objectAtIndex:[thingIndex intValue]] objectForKey:@"text"];
            self.firstEdit = NO;
            self.thingText = text;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = CGSizeMake(screenFrame.size.width, 60);
    
    CAGradientLayer *bgLayer = [BackgroundLayer greyGradient];
    bgLayer.frame = CGRectMake(0, frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height-216-frame.size.height);
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    self.navigationItem.hidesBackButton = YES;
    [[self navigationItem] setTitle:[NSString stringWithFormat:@"Share your %@ thing", [self getNumberWord]]];
    self.navigationController.navigationBar.barTintColor = [[TTNetManager sharedInstance] colorWithHexString:COLOR_YELLOW];
    
	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:screenFrame];
	[navBar setFrame:frame];
	[navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[navBar setItems:[NSArray arrayWithObject:self.navigationItem]];
    
	[self.view addSubview:navBar];
    
    textFieldFrame = CGRectMake(screenFrame.size.width*.05, frame.size.height+20, screenFrame.size.width*.9, screenFrame.size.height-320);
    _textField = [[UITextView alloc] initWithFrame:textFieldFrame];
    _textField.textAlignment = NSTextAlignmentLeft;
    _textField.editable = YES;
    _textField.delegate = self;
    _textField.backgroundColor = [[TTNetManager sharedInstance] colorWithHexString:@"eaeaea"];
    [_textField becomeFirstResponder];
    [_textField setFont:[UIFont systemFontOfSize:15]];
    [_textField setText:self.thingText];
    [self.view addSubview:_textField];
    
    UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imgButton addTarget:self
               action:@selector(imgButtonWasTouched)
     forControlEvents:UIControlEventTouchDown];
    [imgButton setTitle:@"Photo" forState:UIControlStateNormal];
    imgButton.frame = CGRectMake(screenFrame.size.width*.05, textFieldFrame.origin.y+textFieldFrame.size.height-4, 50, 40.0);
    [self.view addSubview:imgButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton addTarget:self
                   action:@selector(saveWasTouched)
         forControlEvents:UIControlEventTouchDown];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(screenFrame.size.width*.55, textFieldFrame.origin.y+textFieldFrame.size.height-4, 50, 40.0);
    [self.view addSubview:saveButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [nextButton addTarget:self
                   action:(self.thingIndex.intValue != 2) ? @selector(nextWasTouched) : @selector(shareWasTouched)
        forControlEvents:UIControlEventTouchDown];
    [nextButton setTitle:(self.thingIndex.intValue != 2) ? @"Next" : @"Share" forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(screenFrame.size.width*.75, textFieldFrame.origin.y+textFieldFrame.size.height-4, 50, 40.0);
    nextButton.layer.borderWidth=1.0f;
    nextButton.layer.borderColor=[[UIColor blackColor] CGColor];
    [self.view addSubview:nextButton];
    
    NSString *imgURL = [[self.shares.theThings objectAtIndex:[self.thingIndex intValue]] objectForKey:@"localImageURL"];
    if (![imgURL isEqualToString:@""]){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
         {
            TTLog(@"Thing image loaded successfully");
            UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(100, textFieldFrame.origin.y+textFieldFrame.size.height+8, 40, 40)];
            picView.image = [UIImage imageWithCGImage:[asset thumbnail]];
            [self.view addSubview:picView];
         }
                failureBlock:^(NSError *error )
         {
             TTLog(@"Error loading thing image");
         }];
    }
}

- (void)cancelWasTouched {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)nextWasTouched {
    [self registerCurrentThing];
    
    [[self navigationController] pushViewController:
     [[EditThingViewController alloc] initWithThingIndex:
      [NSNumber numberWithInt:self.thingIndex.intValue + 1] andShares:self.shares] animated:YES];
}

- (void)saveWasTouched {
    [self registerCurrentThing];
    [self savePartialDay];
    [[self navigationController] pushViewController:
     [[My3ThingsViewController alloc] initWithShareDay:self.shares andIsEdited:[NSNumber numberWithBool:YES]] animated:YES];
}

- (void)shareWasTouched {
    [self registerCurrentThing];
    [self saveDay];
    
    [[self navigationController] pushViewController:
     [[UserHistoryViewController alloc] init] animated:YES];
}

- (void)imgButtonWasTouched {
    TTLog(@"Got callback for image prompt");
    [self.view endEditing:YES];
    PhotoPromptViewController *promptViewController = [[PhotoPromptViewController alloc] init];
    promptViewController.promptDelegate = self;
    [self addChildViewController:promptViewController];
    [self.view addSubview:promptViewController.view];
    promptViewController.view.frame = CGRectMake(0, screenFrame.size.height-180, screenFrame.size.width, 200);
    [promptViewController didMoveToParentViewController:self];
    self.photoPromptIsHidden = YES;
}

- (void)photoWasSelected:(UIImage *)selectedImage {
    TTLog(@"got image: %@", selectedImage);
    int imgWidth = 40;
    UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(100, textFieldFrame.origin.y+textFieldFrame.size.height+8, imgWidth, imgWidth)];
    picView.image = selectedImage;
    [self.view addSubview:picView];
}
- (void)photoWasSaved:(NSURL *)savedPhotoURL {
    TTLog(@"got image url: %@", savedPhotoURL);
    self.thingLocalImageURL = [savedPhotoURL absoluteString];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    TTLog(@"is first edit? %@", [NSNumber numberWithBool:self.firstEdit]);
    if (self.firstEdit) {
        textView.text = @"";
        self.firstEdit = NO;
    }
}

- (void)viewWillLayoutSubviews {
    if (self.photoPromptIsHidden) {
        self.photoPromptIsHidden = NO;
    } else {
        self.photoPromptIsHidden = YES;
    }
}

- (void)viewDidLayoutSubviews {
    if (self.photoPromptIsHidden) {
        [_textField becomeFirstResponder];
    }
}

- (NSString *)getNumberWord
{
    switch (self.thingIndex.intValue) {
        case 0:
            return @"first";
        case 1:
            return @"second";
        case 2:
            return @"third";
        default:
            return @"fifteenth";
    }
}

- (void)savePartialDay{
    TTLog(@"In edit view, in save partial: %@", self.shares.theThings);
    ShareDayStore *dayStore = [[ShareDayStore alloc] init];
    ShareDay *item = [dayStore getToday];
    if (item == NULL){
        item = [dayStore createShareDay];
    }
    for (int i = 0; i < 3; i++){
        if (![[[self.shares.theThings objectAtIndex:i] objectForKey:@"text"] isEqualToString:@""]) {
            Thing *toRemove = NULL;
            for (Thing* oldThing in item.things){
                if ([oldThing.index intValue] == i){
                    toRemove = oldThing;
                }
            }
            if (toRemove != NULL){
                [item removeThingsObject:toRemove];
            }
            Thing *thing = [self saveThingWithIndex:[NSNumber numberWithInt:i]];
            TTLog(@"added thing %d with text %@", i, thing.text);
            [item addThingsObject:thing];
        }
    }
    item.date = [dayStore getDateOnly];
    UserStore *userStore = [[UserStore alloc] init];
    item.user = [userStore getAuthenticatedUser];
    [dayStore saveChanges];
}

- (void)saveDay{
    UserStore *userStore = [[UserStore alloc] init];
    [TTNetManager sharedInstance].netDelegate = self;
    [[TTNetManager sharedInstance] postShareDay:self.shares forUser:[[userStore getAuthenticatedUser] userID]];
    ShareDayStore *dayStore = [[ShareDayStore alloc] init];
    ShareDay *item = [dayStore getToday];
    if (item == NULL){
        item = [dayStore createShareDay];
    }
    NSMutableSet *toRemove = [[NSMutableSet alloc] init];
    for (Thing *thing in item.things){
        [toRemove addObject:thing];
    }
    [item removeThings:toRemove];
    for (int i = 0; i < 3; i++){
        [item addThingsObject:[self saveThingWithIndex:[NSNumber numberWithInt:i]]];
    }
    item.date = [dayStore getDateOnly];
    item.user = [userStore getAuthenticatedUser];
    [dayStore saveChanges];
}

- (Thing *)saveThingWithIndex:(NSNumber *)index {
    ThingStore *thingStore = [[ThingStore alloc] init];
    Thing *thing = [thingStore createThing];
    thing.text = [[self.shares.theThings objectAtIndex:[index intValue]] objectForKey:@"text"];
    thing.localImageURL = [[self.shares.theThings objectAtIndex:[index intValue]] objectForKey:@"localImageURL"];
    thing.index = index;
    return thing;
}

- (void) registerCurrentThing {
    TTLog(@"Registering current thing");
    TTLog(@"Image URL: %@", self.thingLocalImageURL);
    [self.shares.theThings replaceObjectAtIndex:self.thingIndex.intValue
                                     withObject:@{@"text": self.textField.text,
                                         @"localImageURL": (self.thingLocalImageURL == nil) ? @"" : self.thingLocalImageURL}];
}

@end
