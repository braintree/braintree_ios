#import <Expecta/Expecta.h>

EXPMatcherInterface(_deepEqual, (NSDictionary *expected));
#define deepEqual(expected) _deepEqual(EXPObjectify((expected)))
