//
//  TTThing.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTThing : NSObject

- (id) initWithText:(NSString *)text;

@property (nonatomic) NSString *text;
@property (nonatomic) NSString *imageURL;

@end
