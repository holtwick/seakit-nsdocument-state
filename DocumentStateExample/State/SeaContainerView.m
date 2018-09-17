// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import "SeaContainerView.h"

@implementation SeaContainerView

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.wantsLayer = YES;
    self.layer.backgroundColor = self.backgroundColor.CGColor;
}

- (void)prepareForInterfaceBuilder {
    self.wantsLayer = YES;
    self.layer.backgroundColor = self.backgroundColor.CGColor;
}

- (void)setViewController:(NSViewController *)viewController {

    // Avoid useless set
    if(_viewController == viewController || [viewController isEqual:_viewController]) {
        return;
    }

    // Remove old content, new viewcontroller will have different ones
    if (_viewController) {
        [_viewController removeFromParentViewController];
        for (NSView *subView in self.subviews.reverseObjectEnumerator) {
            [subView removeFromSuperview];
        }
    }

    _viewController = viewController;

    if(_viewController) {
        if (self.parentViewController) {
            [self.parentViewController addChildViewController:_viewController];
        }
        NSView *view = _viewController.view;        
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
