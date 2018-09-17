// (C)opyright 2018-06-15 Dirk Holtwick, holtwick.it. All rights reserved.

#import "Document.h"

@interface Document ()
@end

@implementation Document

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSString *)windowNibName {
    return @"Document";    
}

- (NSString *)myMessage {
    return @"Message from NSDocument";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError { 
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return YES;
}

@end
