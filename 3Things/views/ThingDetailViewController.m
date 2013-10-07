//
//  ThingDetailViewController.m
//  3Things
//
//  Created by Emmett Butler on 10/7/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "ThingDetailViewController.h"
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
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:[NSURL URLWithString:[self.thing objectForKey:@"localImageURL"]] resultBlock:^(ALAsset *asset )
     {
         NSLog(@"we have our ALAsset!");
         UIImageView *picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.screenFrame.size.width, 300)];
         picView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
         [self.view addSubview:picView];
     }
            failureBlock:^(NSError *error )
     {
         NSLog(@"Error loading asset");
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
