//
//  CoreDataManager.m
//  CoreDataTest
//
//  Created by 马远征 on 13-12-19.
//  Copyright (c) 2013年 马远征. All rights reserved.
//

#import "CoreDataManager.h"
#import "YZSleepDataOperation.h"
#import "YZSportsDataOperation.h"

@interface CoreDataManager()
{
    NSDateFormatter *_formatter;
}
@property (nonatomic) NSOperationQueue *operationQueue;
@end

@implementation CoreDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static CoreDataManager *manager = nil;
    dispatch_once(&pred, ^{ manager = [[self alloc] init]; });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (NSDateFormatter*)dateFormatter
{
    if (_formatter == nil)
    {
        _formatter = [[NSDateFormatter alloc] init];
    }
    return _formatter;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}
#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Spirograph" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Spirograph.sqlite"];
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSArray*)searchHistoryObject:(NSTimeInterval)utcTime
{
    _formatter = [self dateFormatter];
    [_formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *historyDate = [NSDate dateWithTimeIntervalSince1970:utcTime];
    NSString *historyDateString = [_formatter stringFromDate:historyDate];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History"
                                              inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", historyDateString];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *queryError;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&queryError];
    return fetchedObjects;
}

- (NSArray*)searchObject:(NSTimeInterval)utcTime entityName:(NSString*)entityname
{
    NSDate *historyDate = [NSDate dateWithTimeIntervalSince1970:utcTime];
    _formatter = [self dateFormatter];
    [_formatter setDateFormat:@"yyyy-MM-dd"];
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityname
                                              inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ - utcTime <= 24*3600 ", historyDate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *queryError;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&queryError];
    return fetchedObjects;

}

- (History*)searchHistory:(NSTimeInterval)utcTime
{
    _formatter = [self dateFormatter];
    [_formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *historyDate = [NSDate dateWithTimeIntervalSince1970:utcTime];
    
    History *historyObject = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *fetchesObjects = [self searchHistoryObject:utcTime];
    if (fetchesObjects.count > 0)
    {
        historyObject = [fetchesObjects objectAtIndex:0];
    }
    else
    {
        // 没有查询到记录，插入新对象
        historyObject = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        historyObject.utcTime = [_formatter stringFromDate:historyDate];
    }
    return historyObject;
}

/**
 * @method 插入一个新的step/calorie记录对象
 * @param utcTime   step开始记录时间
 * @param steps     运动记录的步数/每分钟
 * @param calories  运动记录的卡路里/每分钟
 * @return
 */
- (BOOL)insertNewPacketsObject:(NSTimeInterval)utcTime
                         steps:(UInt32)steps
                      calories:(UInt32)calories
{

    History *historyObject = [self searchHistory:utcTime];
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (historyObject == nil)
    {
        DEBUG_STR(@"----[%s]---history对象不存在--",__FUNCTION__);
        return NO;
    }
    
    NSArray *fetchesPacketObjs = [self searchObject:utcTime entityName:@"PacketsRecord"];
    if (fetchesPacketObjs.count > 0)
    {
        DEBUG_STR(@"----[%s]---运动数据记录已经存在--",__FUNCTION__);
        return NO;
    }
    
    PacketsRecord *packetObject = [NSEntityDescription insertNewObjectForEntityForName:@"PacketsRecord"
                                                                inManagedObjectContext:context];
    packetObject.utcTime = [NSDate dateWithTimeIntervalSince1970:utcTime];
    packetObject.stepCount = [NSNumber numberWithUnsignedLong:steps];
    packetObject.calorieCount = [NSNumber numberWithUnsignedLong:calories];
    
    NSSet *packetObjSet = [NSSet setWithObject:packetObject];
    [historyObject addPacketsRecordObject:packetObject];
    [historyObject addPacketsRecord:packetObjSet];
    
    packetObject.history = historyObject;
    
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"【%s】保存packetRecord错误：%@",__FUNCTION__,[error localizedDescription]);
        return NO;
    }
    else
    {
        return YES;
    }
}

/**
 * @method 插入一个新的同步记录，如果记录和数据库的某个记录是同一天则更新当前历史记录
 * @param  utcTime  同步记录上传的时间戳
 * @param  steps    当天的运动步数
 * @param  calories 当天的运动卡里路
 * @param  distance 当天运动行走的距离（stepxstride）
 * @return
 */
- (BOOL)insertNewSyncObject:(NSTimeInterval)utcTime
                      steps:(UInt32)steps
                   calories:(UInt32)calories
                   distance:(UInt32)distance
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSDate *utcDate = [NSDate dateWithTimeIntervalSince1970:utcTime];
    
    _formatter = [self dateFormatter];
    [_formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *utcDateString = [_formatter stringFromDate:utcDate];
    DEBUG_METHOD(@"----插入日期数据----%@",utcDateString);
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SyncRecord" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", utcDateString];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *queryError;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&queryError];
    if (fetchedObjects.count > 0)
    {
        SyncRecord *syncObject = [fetchedObjects objectAtIndex:0];
        syncObject.utcTime = utcDateString;
        syncObject.steps = [NSNumber numberWithUnsignedLong:steps];
        syncObject.distance = [NSNumber numberWithUnsignedLong:distance];
        syncObject.calories = [NSNumber numberWithUnsignedLong:calories];
        
        DEBUG_METHOD(@"---fetchesPacketObjs---%@",fetchedObjects);
        DEBUG_METHOD(@"----[%s]---同步数据记录已经存在--",__FUNCTION__);
    }
    else
    {
        SyncRecord *syncObject = [NSEntityDescription insertNewObjectForEntityForName:@"SyncRecord"
                                                               inManagedObjectContext:context];
        syncObject.utcTime = utcDateString;
        syncObject.steps = [NSNumber numberWithUnsignedLong:steps];
        syncObject.distance = [NSNumber numberWithUnsignedLong:distance];
        syncObject.calories = [NSNumber numberWithUnsignedLong:calories];
    }
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"【%s】保存packetRecord错误：%@",__FUNCTION__,[error localizedDescription]);
        return NO;
    }
    return YES;
}

/**
 * @method 插入一个新的睡眠数据，每5分钟一包
 * @param  utcTime    第一个睡眠数据开始时间
 * @param  sleepData  睡眠数据
 * @return
 */

- (void)insertNewSleepData:(NSData*)data utcTime:(UInt32)utcTime
{
    if (data == nil)
    {
        return;
    }
    if (_operationQueue == nil)
    {
        _operationQueue = [[NSOperationQueue alloc]init];
    }
    YZSleepDataOperation *sleepOperation = [[YZSleepDataOperation alloc]initWithData:data utcTime:utcTime sharedPSC:_persistentStoreCoordinator];
    [_operationQueue addOperation:sleepOperation];
    
}

- (void)insertNewSportData:(NSData*)data utcTime:(UInt32)utcTime
{
    if (data == nil)
    {
        return;
    }
    if (_operationQueue == nil)
    {
        _operationQueue = [[NSOperationQueue alloc]init];
    }
    YZSportsDataOperation *sportOperation = [[YZSportsDataOperation alloc]initWithData:data utcTime:utcTime sharedPSC:_persistentStoreCoordinator];
    [_operationQueue addOperation:sportOperation];
}

- (BOOL)insertNewSleepObject:(NSTimeInterval)utcTime
                   sleepData:(UInt32)sleepData
{
    History *historyObject = [self searchHistory:utcTime];
    NSManagedObjectContext *context = [self managedObjectContext];
    if (historyObject == nil)
    {
        DEBUG_STR(@"----[%s]---history对象不存在--",__FUNCTION__);
        return NO;
    }
    
    NSArray *fetchesPacketObjs = [self searchObject:utcTime entityName:@"SleepDataRecord"];
    if (fetchesPacketObjs.count > 0)
    {
        DEBUG_STR(@"----[%s]---睡眠数据记录已经存在--",__FUNCTION__);
        return NO;
    }
    
    SleepDataRecord *sleepObject = [NSEntityDescription insertNewObjectForEntityForName:@"SleepDataRecord"
                                                           inManagedObjectContext:context];
    sleepObject.utcTime = [NSDate dateWithTimeIntervalSince1970:utcTime];
    sleepObject.sleepData = [NSNumber numberWithUnsignedLong:sleepData];
    
    NSSet *sleepObjSet = [NSSet setWithObject:sleepObject];
    [historyObject addSleepDataRecordObject:sleepObject];
    [historyObject addSleepDataRecord:sleepObjSet];
    
    sleepObject.history = historyObject;
    
    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"【%s】保存packetRecord错误：%@",__FUNCTION__,[error localizedDescription]);
        return NO;
    }
    else
    {
        return YES;
    }
}
@end
