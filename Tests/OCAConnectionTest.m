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
#import "OCASemaphore.h"



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
    id sentValue = @"Sent";
    __block id receivedValue = @"Received";
    
    OCACommand *command = [OCACommand new];
    [command connectTo:[OCASubscriber value:^(id value) {
        receivedValue = value;
    }]];
    
    [command sendValue:sentValue];
    
    XCTAssertTrue(sentValue == receivedValue, @"Received different value.");
}


- (void)test_OCATimer_periodicProductionOfDatesOfLimitedCount {
    OCATimer *timer = [[OCATimer alloc] initWithDelay:0 interval:0.1 leeway:0 count:10];
    OCASemaphore *semaphore = [[OCASemaphore alloc] init];
    __block NSUInteger tickCount = 0;
    
    [timer subscribeValues:^(id value) {
        tickCount ++;
    } finish:^(NSError *error) {
        [semaphore signal];
    }];
    
    BOOL signaled = [semaphore waitFor:10];
    XCTAssertTrue(signaled, @"Timer didn't end in given time.");
    XCTAssertEqual(tickCount, timer.count, @"Timer didn't fire required number of times.");
}





@end
