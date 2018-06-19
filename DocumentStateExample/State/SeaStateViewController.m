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

@implementation SeaStateViewController

+ (NSSet<NSString *> *)keyPathsForValuesAffectingDocument {
    return [NSSet setWithObject:@"representedObject"];
}

- (Document *)document {
    return (id)self.representedObject;
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

//- (void)viewWillAppear {
//    [super viewWillAppear];
//    for (SeaStateObserver *ob in self.binders) {
//        id initialValue = [self valueForKeyPath:ob.keyPath];
//        ob.action(initialValue);
//    }
//}

- (void)cleanupController {
    for (SeaStateObserver *ob in self.binders) {
        [self removeObserver:self
                  forKeyPath:ob.keyPath
                     context:kSeaStateChangeObserver];
    }
    self.binders = nil;
}

- (void)setRepresentedObject:(id)representedObject {
    NSLog(@"set represented object %@", representedObject);
    if (representedObject == self.representedObject || [representedObject isEqual:self.representedObject]) {
        return;
    }
    if (self.representedObject) {
        [self cleanupController];
    }
    [super setRepresentedObject:representedObject];
    if (self.representedObject) {
        [self setupController];
    }
}

@end
