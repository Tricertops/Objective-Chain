//
//  OCAStructMemberAccessor.h
//  Objective-Chain
//
//  Created by Martin Kiss on 3.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCAObject.h"





@interface OCAStructMemberAccessor : OCAObject



- (instancetype)initWithStructType:(const char *)structType
                        memberType:(const char *)memberType
                        memberPath:(NSString *)memberPath
                         isNumeric:(BOOL)isNumeric
                          getBlock:(NSValue *(^)(NSValue *structValue))getBlock
                          setBlock:(NSValue *(^)(NSValue *structValue, NSValue *memberValue))setBlock;

@property (OCA_atomic, readonly, assign) const char *structType;
@property (OCA_atomic, readonly, assign) const char *memberType;
@property (OCA_atomic, readonly, assign) NSString *memberPath;
@property (OCA_atomic, readonly, assign) BOOL isNumeric;

- (NSValue *)memberFromStructure:(NSValue *)structValue;
- (NSValue *)setMember:(NSValue *)memberValue toStructure:(NSValue *)structValue;


+ (BOOL)isNumericType:(const char *)type;


@end



#define OCAStruct(STRUCT, MEMBER) \
({ \
    STRUCT s; \
    const char *structType = @encode(STRUCT); \
    const char *memberType = @encode(typeof(s.MEMBER)); \
    BOOL isNumericMember = (strlen(memberType) == 1 \
                            && strchr("cCsSiIlLqQfd", memberType[0]) != NULL); \
    [[OCAStructMemberAccessor alloc] initWithStructType:structType \
                                             memberType:memberType \
                                             memberPath:@#MEMBER \
                                              isNumeric:isNumericMember \
                                               getBlock:^NSValue *(NSValue *structValue) { \
                                                      typeof(s) structure; \
                                                      [structValue getValue:&structure]; \
                                                      typeof(s.MEMBER) member = structure.MEMBER; \
                                                      if (isNumericMember) \
                                                          return @(member); \
                                                      else \
                                                          return [NSValue valueWithBytes:&member objCType:memberType]; \
                                                  } \
                                                  setBlock:^NSValue *(NSValue *structValue, NSValue *memberValue) { \
                                                      typeof(s) structure; \
                                                      [structValue getValue:&structure]; \
                                                      typeof(s.MEMBER) member; \
                                                      if (isNumericMember) \
                                                          member = [(NSNumber *)memberValue doubleValue]; \
                                                      else \
                                                          [memberValue getValue:&member]; \
                                                      structure.MEMBER = member; \
                                                      return [NSValue valueWithBytes:&structure objCType:structType]; \
                                                  }]; \
}) \


inline id here() {
    CGRect s;
    NSString *memberPath = @"origin.x";
    
    const char *structType = @encode(typeof(s));
    const char *memberType = @encode(typeof(s.origin.x));
    BOOL isNumericMember = [OCAStructMemberAccessor isNumericType:memberType];
    
    return [[OCAStructMemberAccessor alloc] initWithStructType:structType
                                                    memberType:memberType
                                                    memberPath:memberPath
                                                     isNumeric:isNumericMember
                                                      getBlock:^NSValue *(NSValue *structValue) {
                                                          typeof(s) structure;
                                                          [structValue getValue:&structure];
                                                          typeof(s.origin.x) member = structure.origin.x;
                                                          if (isNumericMember)
                                                              return @(member);
                                                          else
                                                              return [NSValue valueWithBytes:&member objCType:memberType];
                                                      }
                                                      setBlock:^NSValue *(NSValue *structValue, NSValue *memberValue) {
                                                          typeof(s) structure;
                                                          [structValue getValue:&structure];
                                                          typeof(s.origin.x) member;
                                                          if (isNumericMember)
                                                              member = [(NSNumber *)memberValue doubleValue]; //TODO: Better universal getter for number. -[NSNumber getNumber:ofType:]
                                                          else
                                                              [memberValue getValue:&member];
                                                          structure.origin.x = member;
                                                          return [NSValue valueWithBytes:&structure objCType:structType];
                                                      }];
}
