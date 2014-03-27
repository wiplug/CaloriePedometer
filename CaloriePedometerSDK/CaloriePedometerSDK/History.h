//
//  History.h
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-3-19.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PacketsRecord, SleepDataRecord;

@interface History : NSManagedObject

@property (nonatomic, retain) NSString * utcTime;
@property (nonatomic, retain) NSSet *packetsRecord;
@property (nonatomic, retain) NSSet *sleepDataRecord;
@end

@interface History (CoreDataGeneratedAccessors)

- (void)addPacketsRecordObject:(PacketsRecord *)value;
- (void)removePacketsRecordObject:(PacketsRecord *)value;
- (void)addPacketsRecord:(NSSet *)values;
- (void)removePacketsRecord:(NSSet *)values;

- (void)addSleepDataRecordObject:(SleepDataRecord *)value;
- (void)removeSleepDataRecordObject:(SleepDataRecord *)value;
- (void)addSleepDataRecord:(NSSet *)values;
- (void)removeSleepDataRecord:(NSSet *)values;

@end
