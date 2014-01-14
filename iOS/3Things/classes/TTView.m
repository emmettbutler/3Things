//
//  TTView.m
//  3Things
//
//  Created by Emmett Butler on 11/19/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import "TTView.h"
#import "TTNetManager.h"

@implementation TTView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    TTLog(@"TTView touch began");
    [super touchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
    if (self.touchDelegate != nil) {
        [self.touchDelegate tableTouchesBegan:touches];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
    if (self.touchDelegate != nil) {
        [self.touchDelegate tableTouchesMoved:touches];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self.nextResponder touchesMoved:touches withEvent:event];
    if (self.touchDelegate != nil) {
        [self.touchDelegate tableTouchesEnded:touches];
    }
}

@end
