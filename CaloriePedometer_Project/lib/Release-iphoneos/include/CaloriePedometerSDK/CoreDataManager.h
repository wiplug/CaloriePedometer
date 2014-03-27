//
//  CoreDataManager.h
//  CoreDataTest
//
//  Created by 马远征 on 13-12-19.
//  Copyright (c) 2013年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "History.h"
#import "PacketsRecord.h"
#import "SyncRecord.h"
#import "SleepDataRecord.h"


@interface CoreDataManager : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstance;
- (void)saveContext;
- (NSDateFormatter*)dateFormatter;
- (NSURL *)applicationDocumentsDirectory;
- (NSManagedObjectContext *)managedObjectContext;


/**
 * @method 插入一个新的step/calorie记录对象
 * @param utcTime   step开始记录时间
 * @param steps     运动记录的步数/每分钟
 * @param calories  运动记录的卡路里/每分钟
 * @return
 */
- (BOOL)insertNewPacketsObject:(NSTimeInterval)utcTime
                          steps:(UInt32)steps
                       calories:(UInt32)calories;

/**
 * @method 插入一个新的同步记录对象（每次同步上传都会插入一次同步记录）
 * @param  utcTime  同步记录上传的时间
 * @param  steps    距上一次同步开始的数据包包含的总步数
 * @param  calories 距上一次同步开始的数据包包含的卡路里总量
 * @param  distance 距上一次同步开始的数据包包含的总距离
 * @return
 */
- (BOOL)insertNewSyncObject:(NSTimeInterval)utcTime
                       steps:(UInt32)steps
                    calories:(UInt32)calories
                   distance:(UInt32)distance;

/**
 * @method 插入一个新的睡眠数据，每5分钟一包
 * @param  utcTime    第一个睡眠数据开始时间
 * @param  sleepData  睡眠数据
 * @return
 */
- (BOOL)insertNewSleepObject:(NSTimeInterval)utcTime
                   sleepData:(UInt32)sleepData;
@end
