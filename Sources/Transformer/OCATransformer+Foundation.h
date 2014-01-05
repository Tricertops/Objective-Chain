//
//  OCATransformer+Foundation.h
//  Objective-Chain
//
//  Created by Martin Kiss on 4.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"





@interface OCAFoundation : OCAObject





#pragma mark NSArray

/// Constructors
//TODO: branchArray: (transformers; create array)
//TODO: wrapObject
//TODO: arrayFromFile

/// Transformators
//TODO: objectsAtIndexes:
//TODO: subarrayToIndex: (also negative)
//TODO: subarrayFromIndex: (also negative)
//TODO: subarrayWithRange:
//TODO: filterArray: (predicate)
//TODO: sortArray:
//TODO: transformArray: (transformer)
//TODO: flattenArray
//TODO: randomizeArray
//TODO: enumerateArray: (block with index)
//TODO: removeDuplicates
//TODO: mutateArray: (block)

/// Destructors
//TODO: objectAtIndex:
//TODO: joinWithString:
//TODO: joinWithString:last:
//TODO: histogram (dictionary, object to its count)


#pragma mark NSAttributedString

/// Constructors
//TODO: stringWithAttributes:

/// Transformators
//TODO: setAttributes:
//TODO: transformAttribute:transformer:
//TODO: appendAttributedString:
//TODO: attributedSubstringInRange:
//TODO: addAttributes:range:
//TODO: mutateAttributedString:(block)


#pragma mark NSData

/// Constructors
//TODO: dataFromFile
//TODO: dataFromString
//TODO: encodeBase64String
//TODO: decodeBase64String
//TODO: archiveBinary:
//TODO: serializePropertyListBinary:
//TODO: serializeJSONPrettyPrinted:

/// Transformators
//TODO: decodeBase64Data
//TODO: encodeBase64Data
//TODO: subdataWithRange:

/// Destructors
//TODO: unarchive
//TODO: deserializePropertyListMutable:
//TODO: deserializeJSONMutable:


#pragma mark NSDate

/// Constructors
//TODO: dateFromTimeInterval
//TODO: dateFromUNIXTimeInterval
//TODO: dateWithFormatter:
//TODO: dateFromStringFormat:

/// Transformators
//TODO: earlierDate:
//TODO: laterDate:
//TODO: addTimeInterval:
//TODO: addDateComponents:
//TODO: subtractDateComponents:

/// Destructors
//TODO: timeInterval
//TODO: timeIntervalSinceNow
//TODO: UNIXTimeInterval
//TODO: timeIntervalSinceDate:
//TODO: stringWithDateFormatter:
//TODO: stringWithDateFormat:
//TODO: stringWithDateStyle:timeStyle:


#pragma mark NSDateComponents

/// Constructors
//TODO: dateComponents:
//TODO: dateComponents:sinceDate:


#pragma mark NSDictionary

/// Constructors
//TODO: dictionaryFromFile
//TODO: mappedArray: (transformer)
//TODO: namedArray: (array of names)
//TODO: dictionaryFromProperties:

/// Transformators
//TODO: filteredDictionary:
//TODO: mutateDictionary: (block)

/// Destructors
//TODO: joinPairsWithString:
//TODO: keysForValue:
//TODO: transformValues:
//TODO: sortedKeysByValues:


#pragma mark NSIndexPath

/// Constructors
//TODO: indexPathFromArray
//TODO: indexPathWithSection:


#pragma mark NSIndexSet

/// Constructors
//TODO: indexSetFromArray
//TODO: wrapIndex
//TODO: wrapRange

/// Destructors
//TODO: lowestIndex
//TODO: highestIndex


#pragma mark NSNumber

/// Constructors
//TODO: numberWithFormatter:

/// Destructors
//TODO: stringWithNumberFormatter:
//TODO: stringWithNumberStyle:
//TODO: stringWithByteCountFormatter:
//TODO: stringWithMemoryByteCount
//TODO: stringWithFileByteCount


#pragma mark NSString

/// Constructors
//TODO: stringFromData
//TODO: formatString: (simply replaces %@ with the value)
//TODO: stringFromFile

/// Transformators
//TODO: appendString:
//TODO: substringToIndex: (also negative)
//TODO: substringFromIndex: (also negative)
//TODO: substringWithRange:
//TODO: replaceString:withString:

/// Destructors
//TODO: splitString:
//TODO: splitWords


#pragma mark NSURL

/// Constructors
//TODO: URLFromString
//TODO: fileURLFromPath
//TODO: URLWithBaseURL:

/// Destructors
//TODO: URLComponents


#pragma mark NSParagraphStyle

/// Transformators
//TODO: mutateParagraphStyle: (block)





@end




