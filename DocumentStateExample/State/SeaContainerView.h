// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "SeaState.h"

/// NSView that pulls a view controler inside
IB_DESIGNABLE
@interface SeaContainerView : NSView
 
@property (strong, nonatomic) IBOutlet NSViewController *viewController;
@property (strong, nonatomic) IBOutlet NSViewController *parentViewController;
@property (strong, nonatomic) IBInspectable NSColor *backgroundColor;

@end
