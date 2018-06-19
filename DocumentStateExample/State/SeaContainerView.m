// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import "SeaContainerView.h"

@implementation SeaContainerView

- (void)setRepresentedObject:(id)representedObject {
    if (representedObject == _representedObject || [representedObject isEqual:_representedObject]) {
        return;
    }

    [self willChangeValueForKey:@"representedObject"];
    _representedObject = representedObject;
    _viewController.representedObject = representedObject; // Pass it on to viewController which will do the same for its subcontrollers
//    for (NSView *view in self.subviews) {
//        if ([view isKindOfClass:[SeaContainerView class]]) {
//            ((SeaContainerView *)view).representedObject = self.representedObject;
//        }
//    }
    [self didChangeValueForKey:@"representedObject"];
}

//- (void)addSubview:(NSView *)view {
//    if ([view isKindOfClass:[SeaContainerView class]]) {
//        ((SeaContainerView *)view).representedObject = self.representedObject;
//    }
//    [super addSubview:view];
//}

- (void)setViewController:(NSViewController *)viewController {

    // Avoid useless set
    if(_viewController == viewController || [viewController isEqual:_viewController]) {
        return;
    }

    // Remove old content, new viewcontroller will have different ones
    if (_viewController) {
        _viewController.representedObject = nil;
        for (NSView *subView in self.subviews.reverseObjectEnumerator) {
            [subView removeFromSuperview];
        }
    }

    _viewController = viewController;

    if(_viewController) {
        NSView *view = _viewController.view;
        _viewController.representedObject = self.representedObject;
        view.frame = self.bounds;
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:view];
        [self.window recalculateKeyViewLoop];
        view.nextResponder = _viewController;
        _viewController.nextResponder = self.superview;
    }
    else {
        [self.window recalculateKeyViewLoop];
    }
}

@end
