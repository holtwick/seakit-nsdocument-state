// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import <Cocoa/Cocoa.h>
#import "SeaState.h"

/// NSView that pulls a view controler inside
@interface SeaContainerView : NSView
@property (nullable, nonatomic, strong) id representedObject;
// @property (weak, nonatomic) IBOutlet NSViewController *viewController;
@property (strong, nonatomic) IBOutlet NSViewController *viewController;
@end