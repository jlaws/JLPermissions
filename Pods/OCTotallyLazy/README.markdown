## OCTotallyLazy - Functional extensions to Objective-C.

OCTotallyLazy is a framework that adds functional behaviour to Objective C collection objects, as well as a lazy collection object called Sequence. It's a partial port of Dan Bodart's TotallyLazy Java library, available here: http://code.google.com/p/totallylazy/

The best place to look for full behaviour is in the test classes for now, checkout https://github.com/stuartervine/OCTotallyLazy/blob/master/src/test-unit/SequenceTest.m

### Importing OCTotallyLazy in your code.

    import <OCTotallyLazy/OCTotallyLazy.h>

### What's available?

NSArray

    drop:
    dropWhile:
    filter:
    find:
    flatMap:
    flatten
    fold: with:
    foreach:
    isEmpty
    groupBy:
    grouped:
    head
    headOption
    join:
    map:
    mapWithIndex:
    merge:
    partition:
    reduce:
    reverse
    splitAt:
    splitOn:
    splitWhen:
    tail
    take:
    takeWhile:
    takeRight:
    toString
    toString:
    toString: separator: end:
    zip:
    zipWithIndex

    asSequence
    asSet
    asDictionary

### Some basic examples.

Mapping (Sequence, NSArray, partially on NSSet, NSDictionary)

    [sequence(@"one", @"two", @"three", nil) map:^(NSString *item){
        return [item uppercaseString];
    }]
    // returns sequence(@"ONE", @"TWO", @"THREE", nil)

    [@[@"one", @[@"two"], @"three"] flatMap:^(NSString *item){
        return [item uppercaseString];
    }];
    // returns array(@"ONE", @"TWO", @"THREE", nil)

Filtering (Sequence, NSArray, NSSet, NSDictionary)

    [sequence(@"1", @"12", @"123", @"1234", nil) filter:^(NSString *item){
        return item.length > 2;
    }]
    //returns sequence(@"123", @"1234", nil)

Options

    [Option option:@"something"];
    //Outputs [Some some:@"something"];

    [Option option:nil];
    //Outputs [None none];

    [[Option option:@"something"] map:^(NSString *item){
        return [item uppercaseString];
    }];
    //Outputs [Some some:@"SOMETHING"];

    [Option option:nil] map:^(NSString *item){
        return [item uppercaseString];
    }];
    //Outputs [None none];

### Shorthand, for the totally lazy

The above examples are still quite noisy. There is shorthand syntax available too. Include the following above the framework import.

    #define TL_SHORTHAND
    #define TL_LAMBDA
    #define TL_LAMBDA_SHORTHAND
    import <OCTotallyLazy/OCTotallyLazy.h>

Then you can do fun stuff such as:

    [sequence(num(1), num(2), num(3), nil) find:not(eqTo(num(1))]; //outputs [Some some:num(2)];

### Lambda craziness

Verbose:

    [sequence(@"bob", @"fred", @"wilma", nil) map:^(NSString *item){return [item uppercaseString];}] //outputs sequence(@"BOB", @"FRED", @"WILMA", nil)

A bit more sane:

    [sequence(@"bob", @"fred", @"wilma", nil) map:lambda(s, [s uppercaseString])] //outputs sequence(@"BOB", @"FRED", @"WILMA", nil)

A bit mental (but a bit like scala):

    [sequence(@"bob", @"fred", @"wilma", nil) map:_([_ uppercaseString])] //outputs sequence(@"BOB", @"FRED", @"WILMA", nil)


### I like it - how do I get it?

So I'm a bit fed up with using 'libraries' that say, just include our source code in your project, or attach our xcode project to your project. So to use this:

- Clone the repo.
- Run <CHECKOUT_DIR>/build.sh test  //optional, but if it fails shout at me!
- Run <CHECKOUT_DIR>/build.sh release
- Copy <CHECKOUT_DIR>/artifacts/OCTotallyLazy.framework to your external libraries folder.
- Import the framework to your project.
- Jobsa good 'un.
    
    
