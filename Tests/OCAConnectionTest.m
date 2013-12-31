//
//  OCAConnectionTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection.h"
#import "OCACommand.h"
#import "OCATimer.h"
#import "OCASubscriber.h"



@interface OCAConnectionTest : XCTestCase

@end





@implementation OCAConnectionTest



- (void)setUp {
    [super setUp];
}


- (void)tearDown {
    [super tearDown];
}





- (void)test_simpleConnection_objectsMustBeIdentical {
    OCACommand *producer = [[OCACommand alloc] init];
    OCAConnection *connection = [[OCAConnection alloc] initWithProducer:producer];
    __block id receivedValue = @"Default";
    OCASubscriber *consumer = [[OCASubscriber alloc] initWithValueHandler:
                               ^(id value){
                                   receivedValue = value;
                               } finishHandler:nil];
    connection.consumer = consumer;
    
    id sentValue = @"Value";
    [producer sendValue:sentValue];
    
    XCTAssertTrue(sentValue == receivedValue, @"Received different value.");
}


- (void)test_OCATimer_periodicProductionOfDatesOfLimitedCount {
    NSUInteger designatedTickCount = 10;
    OCATimer *timer = [[OCATimer alloc] initWithDelay:0 interval:0.1 leeway:0 count:designatedTickCount];
    OCAConnection *connection = [[OCAConnection alloc] initWithProducer:timer];
    __block NSUInteger tickCount = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    OCASubscriber *consumer = [[OCASubscriber alloc] initWithValueHandler:
                               ^(NSDate *date){
                                   tickCount ++;
                               } finishHandler:^(NSError *error){
                                   dispatch_semaphore_signal(semaphore);
                               }];
    connection.consumer = consumer;
    
    BOOL timedOut = dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (2 * NSEC_PER_SEC)));
    XCTAssertFalse(timedOut, @"Timer didn't end in given time.");
    XCTAssertEqual(tickCount, designatedTickCount, @"Timer didn't fire required number of times.");
}





@end
