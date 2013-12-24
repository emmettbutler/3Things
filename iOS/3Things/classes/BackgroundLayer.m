#import "BackgroundLayer.h"
#import "TTNetManager.h"

@implementation BackgroundLayer

// http://danielbeard.wordpress.com/2012/02/25/gradient-background-for-uiview-in-ios/

// Metallic grey gradient background
+ (CAGradientLayer*) greyGradient {
    UIColor *colorOne = [[TTNetManager sharedInstance] colorWithHexString:@"FFFFFF"];
    UIColor *colorTwo = [[TTNetManager sharedInstance] colorWithHexString:@"d2d3d5"];
    UIColor *colorThree     = [[TTNetManager sharedInstance] colorWithHexString:@"dedfe0"];
    UIColor *colorFour = [[TTNetManager sharedInstance] colorWithHexString:@"e9e9ea"];
    
    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, nil];
    
    NSNumber *stopOne = @(0.0);
    NSNumber *stopTwo = @(0.02);
    NSNumber *stopThree = @(0.99);
    NSNumber *stopFour = @(1.0);
    
    NSArray *locations = @[stopOne, stopTwo, stopThree, stopFour];
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    
    return headerLayer;
    
}

@end
