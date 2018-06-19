// (C)opyright 2018-06-18 Dirk Holtwick, holtwick.it. All rights reserved.

#import "ContentBViewController.h"

@interface ContentBViewController ()

@end

@implementation ContentBViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (NSArray *)content {
    return @[ @"Lorem",
              @"ipsum",
              @"dolor",
              @"sit",
              @"amet"];
}

@end
