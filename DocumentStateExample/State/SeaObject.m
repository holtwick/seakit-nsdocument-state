// (C)opyright 2018-04-25 Dirk Holtwick, holtwick.it. All rights reserved.

#import "SeaObject.h"
#import <objc/runtime.h>

@implementation SeaObject {
    __strong NSMutableDictionary *_properties;
    BOOL _needsSave;
}

+ (void)initialize {
    [super initialize];
    if (self != [SeaObject self]) {
        NSArray *danger = [self getDangerousPropertyNames];
        if (danger) {
            //            cerror(@"sea", @"In class <%@> dangerous properties have been identified. Add the follwing code:\n\n@dynamic %@\n",
            //                   NSStringFromClass(self),
            //                   [danger componentsJoinedByString:@", "]);
#if DEBUG && MAC
            NSBeep();
#endif
            id reason = [NSString stringWithFormat:@"In class <%@> dangerous properties have been identified. Add the follwing code: @dynamic %@",
                         NSStringFromClass(self),
                         [danger componentsJoinedByString:@", "]];
            @throw [NSException exceptionWithName:@"Missing @dynamic"
                                           reason:reason
                                         userInfo:nil];
        }
    }
}

- (void)setJsonDictionary:(NSDictionary *)obj {
    [self willChangeValueForKey:@"allKeys"];
    if (obj) {
        _properties = [self cleanedObject:obj forImport:YES];
    }
    if (!_properties) {
        _properties = [NSMutableDictionary dictionary];
    }
    [self didChangeValueForKey:@"allKeys"];
}

- (NSMutableDictionary *)jsonDictionary  {
    return [self cleanedObject:_properties forImport:NO] ?: [NSMutableDictionary dictionary];
}

- (void)configure {
    // Can be overridden
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setJsonDictionary:dict];
        [self configure];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setJsonDictionary:nil];
        [self configure];
    }
    return self;
}

#pragma mark - Subclassing

- (NSUInteger)count {
    return _properties.count;
}

- (id)objectForKey:(id)aKey {
    NSLog(@"objectForKey:%@ => %@", aKey, [_properties objectForKey:aKey]);
    return [_properties objectForKey:aKey];
}

- (void)setObject:(id)value forKey:(id<NSCopying>)aKey {
    NSString *key = (id)aKey;
    if (!value) {
        [self removeObjectForKey:key];
    } else {
        // Asset, Reference
        //        if (!([value isKindOfClass:[NSNumber class]] ||
        //              [value isKindOfClass:[NSArray class]] ||
        //              [value isKindOfClass:[NSDictionary class]] ||
        //              [value isKindOfClass:[SeaObject class]] ||
        //              [value isKindOfClass:[NSString class]]
        //              )) {
        //            @throw [NSString stringWithFormat:@"Unsupported object class %@", NSStringFromClass([value class])];
        //        }
        id oldValue = [_properties objectForKey:key];
        if (oldValue != value && ![oldValue isEqual:key]) {
            [self willChangeValueForKey:key];
            [_properties setObject:value forKey:key];
            NSLog(@"setObject:%@ forKey:%@", value, key);
            [self didChangeValueForKey:key];
            self.needsSave = YES;
        }
    }
}

- (void)removeObjectForKey:(id)key {
    id oldValue = [_properties objectForKey:key];
    if (oldValue) {
        [self willChangeValueForKey:key];
        [_properties removeObjectForKey:key];
        [self didChangeValueForKey:key];
    }
}

- (NSEnumerator *)keyEnumerator {
    return _properties.keyEnumerator;
}

- (NSArray<NSString *> *)allKeys {
    return _properties.allKeys;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self setObject:obj forKey:key];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    XLogDebug(@"setValue:%@ forUndefinedKey:%@", value, key);
    [self setObject:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key {
//    XLogDebug(@"valueForUndefinedKey:%@", key);
    return [self objectForKey:key];
}

#pragma mark - Serializing

- (id)cleanedObject:(id)objectToBeCleaned forImport:(BOOL)forImport {
    if (!objectToBeCleaned) {
        return nil;
    }
    __strong id obj = objectToBeCleaned;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (forImport) {
            SeaObject *dict = [[SeaObject alloc] initWithDictionary:nil];
            for(id key in obj) {
                id value = [obj objectForKey:key];
                if (value) { // Strip null
                    value = [self cleanedObject:value forImport:forImport];
                    if (value) { // Strip null
                        dict[key] = value;
                    }
                }
            }
            obj = dict;
        }
        else {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for(id key in obj) {
                id value = [obj objectForKey:key];
                if (value) { // Strip null
                    value = [self cleanedObject:value forImport:forImport];
                    if (value) { // Strip null
                        dict[key] = value;
                    }
                }
            }
            obj = dict;
        }
    }
    else if ([obj isKindOfClass:[SeaObject class]]) {
        if (!forImport) {
            obj = [obj jsonDictionary];
        }
    }
    else if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSSet class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for(id value in obj) {
            if (value) { // Strip null
                [array addObject:[self cleanedObject:value forImport:forImport]];
            }
        }
        obj = array;
    }
    return obj;
} 

#pragma mark - Check dynamic properties!

+ (NSArray *)getDangerousPropertyNames { // https://stackoverflow.com/a/11774276/140927
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    NSMutableArray *dangerousPropertiyNames = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        NSString *attr = @(property_getAttributes(property));
        if ([attr containsString:@",V_"]) {
            [dangerousPropertiyNames addObject:name];
        }
    }
    free(properties);
    return dangerousPropertiyNames.count > 0 ? dangerousPropertiyNames : nil;
}

#pragma mark - Dynamic Properties

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSString *sel = NSStringFromSelector(selector);
    // XLogDebug(@"methodSignatureForSelector:%@", sel);
    if ([sel rangeOfString:@"set"].location == 0) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    } else {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector(invocation.selector);
    // XLogDebug(@"forwardInvocation:%@", sel);
    if ([sel rangeOfString:@"set"].location == 0) {
        sel = [NSString stringWithFormat:@"%@%@",
               [sel substringWithRange:NSMakeRange(3, 1)].lowercaseString,
               [sel substringWithRange:NSMakeRange(4, sel.length-5)]];
        id __unsafe_unretained obj;
        [invocation getArgument:&obj atIndex:2];
        [self setObject:obj forKey:sel];
    } else {
        id obj = [_properties objectForKey:sel];
        [invocation setReturnValue:&obj];
    }
}

#pragma mark - Debug

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@\n _properties=%@>",
            self.className,
            _properties];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self.class alloc] initWithDictionary:[self jsonDictionary].copy];
}

@end
