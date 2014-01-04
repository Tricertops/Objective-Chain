//
//  OCATransformer+Foundation.h
//  Objective-Chain
//
//  Created by Martin Kiss on 4.1.14.
//  Copyright (c) 2014 Martin Kiss. All rights reserved.
//

#import "OCATransformer.h"





@interface OCAFoundation : OCAObject


//TODO: count
//TODO: length
//TODO: copy

//TODO: valueOfProperty:
//TODO: branchProperty:transformer:
//TODO: setValue:ofProperty:

//TODO: valueForKeyPath:
//TODO: valuesForKeyPaths:
//TODO: setValue:forKeyPath:
//TODO: setValuesForKeyPaths:


#pragma mark NSArray

//TODO: arrayFromSet
//TODO: arrayFromOrderedSet
//TODO: arrayFromIndexSet
//TODO: arrayFromIndexPath
//TODO: arrayFromHashTable
//TODO: branchArray:
//TODO: objectAtIndex:
//TODO: objectsAtIndexes:
//TODO: arrayFromPath
//TODO: arrayFromURL
//TODO: joinWithString:
//TODO: joinWithString:last:
//TODO: subarrayToIndex:
//TODO: subarrayFromIndex: (also negative)
//TODO: subarrayWithRange:
//TODO: indexOfObject:identical:
//TODO: filter:
//TODO: filterSubarray:count:
//TODO: sort:
//TODO: transform:
//TODO: addObject:
//TODO: removeObject:
//TODO: addObjects:
//TODO: removeObjects:
//TODO: wrapInArray
//TODO: flattenArray
//TODO: mutateArray:(block)



#pragma mark NSAttributedString

//TODO: stringWithAttributes:
//TODO: enumerateAttribute:inRange:transformer:
//TODO: appendAttributedString:
//TODO: attributedSubstringInRange:
//TODO: addAttributes:range:
//TODO: mutateAttributedString:(block)


#pragma mark NSCharacterSet

//TODO: characterSetFromString
//TODO: NSString trimCharactersInSet:
//TODO: NSString removeCharactersInSet:


#pragma mark NSCountedSet

//TODO: dictionaryFromCountedSet
//TODO: countedSetFromArray

#pragma mark NSData

//TODO: dataFromPath
//TODO: dataFromURL
//TODO: dataFromStringUsingEncoding:
//TODO: dataFromString
//TODO: decodeBase64Data
//TODO: decodeFromBase64String
//TODO: encodeBase64Data
//TODO: encodeBase64String
//TODO: subdataInRange:


#pragma mark NSDataDetector

//TODO: detectDataTypes:
//TODO: detectDatesInString
//TODO: detectURLsInString
//TODO: detectAddressesInString
//TODO: detectPhoneNumbersInString
//TODO: detectTransitInformationsInString


#pragma mark NSDate

//TODO: dateFromTimeInterval
//TODO: dateFromTimeIntervalSince1970
//TODO: earlierDate:
//TODO: laterDate:
//TODO: timeInterval
//TODO: timeIntervalSinceNow
//TODO: timeIntervalSince1970
//TODO: timeIntervalSinceDate:
//TODO: addTimeInterval:


#pragma mark NSDateComponents

//TODO: dateComponents:
//TODO: dateComponents:sinceDate:
//TODO: addDateComponents:wrap:
//TODO: subtractDateComponents:wrap:


#pragma mark NSDateFormatter

//TODO: stringWithDateFormatter:
//TODO: dateWithFormatter:
//TODO: stringWithDateFormat:
//TODO: stringWithDateStyle:timeStyle:
//TODO: dateFromStringFormat:


#pragma mark NSDictionary

//TODO: dictionaryFromPath
//TODO: dictionaryFromURL
//TODO: dictionaryFromMapTable
//TODO: translateDictionary:
//TODO: joinPairsWithString:
//TODO: dictionaryFromArrayUsing:(transformer)
//TODO: dictionaryWithValuesForKeyPaths:
//TODO: allKeys
//TODO: allValues
//TODO: objectForKey:
//TODO: keysForObject:
//TODO: transformObjects:
//TODO: transformKeys:
//TODO: sortedKeysByValues:(sort descriptors)
//TODO: filteredDictionary:
//TODO: namedArray: (create dictionary from array by naming the elements)
//TODO: mutateDictionary:(block)


#pragma mark NSExpression

//TODO: evaluateExpression:


#pragma mark NSHashTable


//TODO: weakHashTableFromArray
//TODO: weakHashTableFromSet
//TODO: weakHashTableFromOrderedSet


#pragma mark NSIndexPath

//TODO: indexPathFromArray
//TODO: indexPathWithFirstIndex:
//TODO: indexAtPosition:
//TODO: indexPathSection
//TODO: indexPathRow
//TODO: indexPathItem


#pragma mark NSIndexSet

//TODO: indexSetFromArray
//TODO: indexSetFromSet
//TODO: indexSetFromIndex
//TODO: indexSetFromRange
//TODO: lowestIndexInSet
//TODO: highestIndexInSet
//TODO: mutateIndexSet:(block)


#pragma mark NSKeyedArchiver

//TODO: archiveObject
//TODO: archiveObjectUsingXML


#pragma mark NSKeyedUnarchiver

//TODO: unarchiveObject


#pragma mark NSLocale

//TODO: localeFromIdentifier
//TODO: localeLanguageCode
//TODO: localeCountryCode
//TODO: calendarFromLocale


#pragma mark NSMapTable

//TODO: weakToWeakMapTableFromDictionary
//TODO: weakToStrongMapTableFromDictionary
//TODO: strongToWeakMapTableFromDictionary
//TODO: strongToStrongMapTableFromDictionary


#pragma mark NSNull

//TODO: replaceNilsWithNulls
//TODO: replaceNullsWithNils


#pragma mark NSNumberFormatter

//TODO: stringWithNumberFormatter:
//TODO: numberWithFormatter:
//TODO: stringWithNumberStyle:


#pragma mark NSOrderedSet

//TODO: orderedSetFromArray
//TODO: orderedSetFromSet
//TODO: orderedSetFromHashTable
//TODO: mutateOrderedSet:(block)


#pragma mark NSPredicate

//TODO: filter:replacement:


#pragma mark NSPropertyListSerialization

//TODO: serializePropertyList
//TODO: deserializePropertyList
//TODO: deserializeMutablePropertyList


#pragma mark NSRegularExpression

//TODO: numberOfRegexMatchesInString
//TODO: regexMatchesInString
//TODO: firstRegexMatchInString


#pragma mark NSSet

//TODO: setFromArray
//TODO: setFromOrderedSet
//TODO: setFromHashTable


#pragma mark NSString

//TODO: stringFromDataUsingEncoding:
//TODO: stringFromData
//TODO: stringFromNumber
//TODO: stringWithFormat: (simply replaces %@ with the value)
//TODO: stringFromPath
//TODO: stringFromURL
//TODO: appendString:
//TODO: appendToString:
//TODO: splitByString:
//TODO: splitByCharacters:
//TODO: splitWords
//TODO: trimCharacters:
//TODO: substringToIndex:
//TODO: substringFromIndex: (with negative)
//TODO: substringWithRange:
//TODO: replaceString:withString:
//TODO: transformSubstringInRange:transformer:
//TODO: numberFromString
//TODO: pathFromComponents
//TODO: appendPathComponent:
//TODO: appendPathExtension:
//TODO: deleteLastPathComponent
//TODO: deletePathExtension
//TODO: appendPaths:


#pragma mark NSURL

//TODO: URLFromString
//TODO: fileURLFromPath
//TODO: URLFromComponents
//TODO: URLWithBaseURL:


#pragma mark NSURLComponents

//TODO: componentsFromURL
//TODO: componentsFromURLString


#pragma mark NSUUID

//TODO: UUIDFromString


#pragma mark NSParagraphStyle

//TODO: mutateParagraphStyle:(block)


#pragma mark NSJSONSerialization

//TODO: serializeJSONPrettyPrinted:
//TODO: deserializeJSON
//TODO: deserializeMutableJSON


#pragma mark NSByteCountFormatter

//TODO: stringWithByteCountFormatter:
//TODO: stringWithMemoryByteCount
//TODO: stringWithFileByteCount




@end




