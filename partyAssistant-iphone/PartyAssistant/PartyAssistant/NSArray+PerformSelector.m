

#import "NSArray+PerformSelector.h"


@implementation NSArray (PerformSelector)

- (NSArray *)arrayByPerformingSelector:(SEL)selector {
    NSMutableArray * results = [NSMutableArray array];

    for (id object in self) {
        id result = [object performSelector:selector];
        [results addObject:result];
    }

    return results;
}

@end
