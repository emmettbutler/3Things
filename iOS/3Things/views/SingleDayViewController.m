//
//  SingleDayViewController.m
//  3Things
//
//  Created by Emmett Butler on 11/11/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>

#import "SingleDayViewController.h"
#import "UserStore.h"
#import "ShareDayStore.h"
#import "TTNetManager.h"
#import "Thing.h"
#import "ThingDetailViewController.h"
#import "ErrorThrowingViewController.h"
#import "EditThingViewController.h"

@interface SingleDayViewController ()

@end

@implementation SingleDayViewController

- (id)initWithIsCurrent:(NSNumber *)isCurrent {
    return [self initWithShareDay:NULL andIsCurrent:isCurrent];
}

- (id)initWithShareDay:(TTShareDay *)shares {
    return [self initWithShareDay:shares andIsCurrent:[NSNumber numberWithBool:NO]];
}

-(id)initWithShareDay:(TTShareDay *)shares andIsCurrent:(NSNumber *)isCurrent
{
    self = [super init];
    if (self) {
        self.isCurrent = [isCurrent boolValue];
        self.completedThings = [NSNumber numberWithInt:self.isCurrent ? 0 : 3];
        self.shares = shares;
        TTLog(@"Entering single day view: %@", self.shares.theThings);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect screenFrame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-20);
    CGRect scrollFrame = CGRectMake(10, 90, screenFrame.size.width*.9, 300);
    TTLog(@"Scroll frame: (%fx%f)", scrollFrame.size.width, scrollFrame.size.height);
    self.frame = scrollFrame;

    UICollectionViewFlowLayout* flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setItemSize:CGSizeMake(scrollFrame.size.width, (scrollFrame.size.height)/3)];
    UICollectionView *tableView = [[UICollectionView alloc] initWithFrame:scrollFrame collectionViewLayout:flow];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    [tableView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyReuseIdentifier"];
    [tableView reloadData];
    [self.view addSubview:tableView];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTLog(@"In collectionView cellForItem");
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MyIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    CGRect frame = cell.bounds;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.backgroundView.bounds.size.width, cell.backgroundView.bounds.size.height)];
    
    NSString *text = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"text"];
    if ([text isEqualToString:@""]) {
        text = @"Share something...";
    } else {
        self.completedThings = [NSNumber numberWithInt:[self.completedThings intValue] + 1];
        TTLog(@"Counted completed thing for day: %d", [self.completedThings intValue]);
        if([self.completedThings intValue] == 3) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d", kDayComplete]];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UITextView *thingTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    [thingTextView setText:text];
    [thingTextView setFont:[UIFont systemFontOfSize:20]];
    [container addSubview:thingTextView];
    
    NSString *imgURL = [[self.shares.theThings objectAtIndex:indexPath.row] objectForKey:@"localImageURL"];
    if (![imgURL isEqualToString:@""]){
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:[NSURL URLWithString:imgURL] resultBlock:^(ALAsset *asset )
         {
             TTLog(@"thing image loaded at index %d", indexPath.row);
             UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 0, 40, 40)];
             picView.image = [UIImage imageWithCGImage:[asset thumbnail]];
             [container addSubview:picView];
         }
                failureBlock:^(NSError *error )
         {
             TTLog(@"Error loading thing image at index %d", indexPath.row);
         }];
    }
    cell.backgroundView = container;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (((ErrorThrowingViewController *)self.parentViewController).errViewIsShown) return;
    TTLog(@"Entering editor: %@", self.shares.theThings);
    if (self.isCurrent) {
        UIViewController *editView = [[EditThingViewController alloc] initWithThingIndex:[NSNumber numberWithInt:indexPath.row] andShares:self.shares];
        [[self navigationController] pushViewController:editView animated:YES];
    } else {
        ThingDetailViewController *detailView = [[ThingDetailViewController alloc] initWithThing:[self.shares.theThings objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:detailView animated:YES];
    }
}

@end
