// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "SeaState.h"
#import "SeaContainerView.h"
#import "Document.h"

@interface SeaStateViewController : NSViewController 

@property (readonly) Document *document;

- (void)setupController;
- (void)cleanupController;

- (void)observeKeyPath:(NSString *)keyPath action:(void (^)(id newValue))block;

@end
