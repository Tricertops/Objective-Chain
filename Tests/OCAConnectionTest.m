//
//  OCAConnectionTest.m
//  Objective-Chain
//
//  Created by Martin Kiss on 30.12.13.
//
//

#import "OCAConnection.h"
#import "OCACommand.h"
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





@end
