// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import "SeaStateViewController.h"

static void *kSeaStateChangeObserver = &kSeaStateChangeObserver;

@interface SeaStateObserver : NSObject
@property NSString *keyPath;
@property void (^action)(id newValue);
@end

@implementation SeaStateObserver
@end

//

@interface SeaStateViewController ()
@property NSMutableArray <SeaStateObserver *> *binders;
@end

@implementation SeaStateViewController {
    __weak Document *_document;
    BOOL _bound;
}

- (void)setDocument:(Document *)document {
    if (document == self.document || [document isEqual:self.document]) {
        return;
    }
    if (_document) {
        [self cleanupController];
    }
    [self willChangeValueForKey:@"document"];
    _document = document;
    [self didChangeValueForKey:@"document"];
    if (_document) {
        [self setupController];
    }
}

- (Document *)document {
    return _document;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    self.document = self.view.window.windowController.document;
}

- (void)viewDidDisappear {
    self.document = nil;
    [super viewDidDisappear];
}

- (void)dealloc {
    self.document = nil;
}

- (void)observeKeyPath:(NSString *)keyPath action:(void (^)(id newValue))block {
    SeaStateObserver *ob = [[SeaStateObserver alloc] init];
    ob.keyPath = keyPath;
    ob.action = block;
    [self.binders addObject:ob];
    
    @try {
        id initialValue = [self valueForKeyPath:keyPath];
        block(initialValue);
    }
    @catch (id ex) {
        NSLog(@"Exception: %@", [ex description]);
    }
    
    [self addObserver:self
           forKeyPath:keyPath
              options:0
              context:kSeaStateChangeObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == kSeaStateChangeObserver) {
        for (SeaStateObserver *ob in self.binders) {
            if ([keyPath isEqualToString:ob.keyPath]) {
                // NSLog(@"do %@ %@", object, change);
                ob.action([self valueForKeyPath:ob.keyPath]);
                // return;
            }
        }
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setupController {
    self.binders = [[NSMutableArray alloc] init];
}

- (void)cleanupController {
    for (SeaStateObserver *ob in self.binders) {
        [self removeObserver:self
                  forKeyPath:ob.keyPath
                     context:kSeaStateChangeObserver];
    }
    self.binders = nil;
}

@end
