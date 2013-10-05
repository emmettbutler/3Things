//
//  ThingStore.h
//  3Things
//
//  Created by Emmett Butler on 10/5/13.
//  Copyright (c) 2013 Emmett Butler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDataStore.h"
#import "Thing.h"

@interface ThingStore : TTDataStore

- (Thing *)createThing;
- (NSArray *)allItems;

@end
