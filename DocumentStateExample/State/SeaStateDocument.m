// (C)opyright 2018-06-16 Dirk Holtwick, holtwick.it. All rights reserved.

#import "SeaStateDocument.h"

@interface SeaStateDocument ()
@property NSUndoManager *stateStack;
@property SeaState *lastStoredState;
@end

@implementation SeaStateDocument

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = [[SeaState alloc] init];
        self.state.selection = @"bbb"; // Initial value
        self.lastStoredState = self.state.copy;
        self.stateStack = [[NSUndoManager alloc] init];
    }
    return self;
}

#pragma mark - State Navigation

- (void)restoreState:(SeaState *)state {
    NSLog(@"Restore state: %@", state);
    [self storeState];
    self.state = state;
}

- (void)updateState:(SeaState *(^)(SeaState *state))block {
    id newState = block(self.state);
    if (newState) {
        self.state = newState;
    }
}

- (void)storeState {
    if (![self.state isEqual:self.lastStoredState]) {
        NSLog(@"Store state %@", self.state);
        self.lastStoredState = self.state.copy;
        [self.stateStack registerUndoWithTarget:self
                                       selector:@selector(restoreState:)
                                         object:self.lastStoredState];
    }
}

- (IBAction)doGoBack:(id)sender {
    [self.stateStack undo];
}

- (IBAction)doGoForward:(id)sender {
    [self.stateStack redo];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    if (item.action == @selector(doGoBack:)) {
        return self.stateStack.canUndo;
    }
    if (item.action == @selector(doGoForward:)) {
        return self.stateStack.canRedo;
    }
    return [super validateUserInterfaceItem:item];
}

#pragma mark - Pass document as represented object

- (void)addWindowController:(NSWindowController *)windowController {
    [super addWindowController:windowController];
    hxApply1(windowController.window.contentViewController, @selector(setRepresentedObject:), self);
    hxApply1(windowController.window.contentView, @selector(setRepresentedObject:), self);
}

- (void)removeWindowController:(NSWindowController *)windowController {
    hxApply1(windowController.window.contentView, @selector(setRepresentedObject:), nil);
    hxApply1(windowController.window.contentViewController, @selector(setRepresentedObject:), nil);
    [super removeWindowController:windowController];
}

@end
