// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import <Foundation/Foundation.h>
#import "SeaObject.h"

@interface SeaState : SeaObject // SeaObject is only for some KVO and serialization magic
@property NSString *uuid;
@property NSString *selection;
@property NSString *search;
@property NSNumber *firstResponderTag;
@property NSIndexSet *tabsel;
@end
 

