// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import "MainViewController.h"
#import "ContentAViewController.h"
#import "ContentBViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

// Example for subviews
- (void)showViewControllerBy:(id)by {
    NSLog(@"$ show %@", by);
    if ([by isEqualToString:@"aaa"]) {
        self.containerView.viewController = [[ContentAViewController alloc] init];
    }
    else if ([by isEqualToString:@"bbb"]) {
        self.containerView.viewController = [[ContentBViewController alloc] init];
    }
    else {
        self.containerView.viewController = nil;
    }
}

- (void)setupController {
    __weak typeof(self) weakSelf = self;

    [super setupController];

    self.containerView.representedObject = self.representedObject;

    [self observeKeyPath:@"document.state.selection" action:^(id newValue) {
        typeof(self) self = weakSelf;
        [self showViewControllerBy:self.document.state.selection];
    }];

    [self observeKeyPath:@"document.state.search" action:^(id newValue) {
        typeof(self) self = weakSelf;
        NSLog(@"Search %@", self.document.state.search);
    }];
}

- (void)viewDidAppear {
    [super viewWillAppear];

    __weak typeof(self) weakSelf = self;
    [self observeKeyPath:@"document.state.firstResponderTag" action:^(id newValue) {
        NSInteger tag = [newValue integerValue];
        if (tag > 0) {
            typeof(self) self = weakSelf;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSView *keyViewCandidate = [self.view.window.contentView viewWithTag:tag];
                NSView *currentKeyView = (NSView *)self.view.window.firstResponder;
                if (keyViewCandidate && ![keyViewCandidate isEqual:currentKeyView]) {
                    [self.view.window makeFirstResponder:keyViewCandidate];
                }
            }];
        }
    }];
    
    [self observeKeyPath:@"view.window.firstResponder" action:^(id newValue) {
        typeof(self) self = weakSelf;
        
        NSLog(@"firstResponder: %@", newValue);
        
        NSInteger tag = -1;
        NSView *currentKeyView = (NSView *)self.view.window.firstResponder;
        while (currentKeyView && [currentKeyView isKindOfClass:[NSView class]] /*&& [currentKeyView isDescendantOf:self.view]*/ ) {
            tag = currentKeyView.tag;
            if (tag > 0) {
                break;
            }
            currentKeyView = currentKeyView.superview;
        }
        
        NSLog(@"Tag %@#", @(tag));
        if (tag > 0) {
            self.document.state.firstResponderTag = @(tag);
        }
    }];
}

#pragma mark - Actions

- (IBAction)doSelectA:(id)sender {
    [self.document storeState];
    self.document.state.selection = @"aaa";
}

- (IBAction)doSelectB:(id)sender {
    [self.document storeState];
    self.document.state.selection = @"bbb";
}

@end
