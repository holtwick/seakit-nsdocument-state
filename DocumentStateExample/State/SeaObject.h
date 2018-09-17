// (C)opyright 2018-04-25 Dirk Holtwick, holtwick.it. All rights reserved.

#import <Foundation/Foundation.h>

// Avoid compiler warnings

#if __clang__
#define hxPushArgs _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Weverything\"")
#define hxPopArgs _Pragma("clang diagnostic pop")
#else
#define hxPushArgs
#define hxPopArgs
#endif

// Apply methods

#define hxApply0(target, sel)             (  hxPushArgs ([((NSObject *)(target)) respondsToSelector:(sel)] ? [((NSObject *)(target)) performSelector:(sel)] : nil) hxPopArgs )
#define hxApply1(target, sel, obj)        (  hxPushArgs ([((NSObject *)(target)) respondsToSelector:(sel)] ? [((NSObject *)(target)) performSelector:(sel) withObject:(obj)] : nil) hxPopArgs )
#define hxApply2(target, sel, obj, obj2)  (  hxPushArgs ([((NSObject *)(target)) respondsToSelector:(sel)] ? [((NSObject *)(target)) performSelector:(sel) withObject:(obj) withObject:(obj2)] : nil) hxPopArgs )


/*   A dictionary like object that allows to define custom dynamic properties
 *   for typed and easy access. Only simple types like string, number, array and
 *   dictionary are supported. It is mainly thought to be a convenience class that
 *   can be serialized easily to JSON and other formats.
 *
 *   MAKE SURE to add @dynamic for any property you define in a subclass of SeaObject!
 *
 *   More details at https://holtwick.de/blog/seaobject
 */

@protocol SeaObjectDelegate
@optional

@end

@interface SeaObject : NSObject <NSCopying>

@property id<SeaObjectDelegate> delegate;

@property (nonatomic, assign) BOOL needsSave;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSEnumerator *keyEnumerator;
@property (nonatomic, readonly) NSArray<NSString *> *allKeys;
@property (nonatomic, copy) NSDictionary *jsonDictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)configure;

- (id)objectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey;
- (void)removeObjectForKey:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (id)objectForKeyedSubscript:(NSString *)key;

@end
