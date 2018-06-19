// (C)opyright 2018-06-16 Dirk Holtwick, holtwick.it. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "SeaState.h"

@interface SeaStateDocument : NSDocument

@property (strong) SeaState *state;

- (void)storeState;

- (IBAction)doGoBack:(id)sender;
- (IBAction)doGoForward:(id)sender;

@end
