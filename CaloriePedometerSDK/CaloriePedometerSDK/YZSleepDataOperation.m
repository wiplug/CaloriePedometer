//
//  YZSleepDataOperation.m
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-3-26.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "YZSleepDataOperation.h"
#import "History.h"
#import "SleepDataRecord.h"

@interface YZSleepDataOperation()
@property (nonatomic, strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic, strong) NSManagedObjectContext *managerObjectContext;
@property (nonatomic,   copy) NSData *receiveData;
@property (nonatomic, assign) UInt32 utcTime;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation YZSleepDataOperation

- (id)initWithData:(NSData*)receiveData utcTime:(UInt32)utcTime sharedPSC:(NSPersistentStoreCoordinator*)psc
{
    self = [super init];
    if (self)
    {
        _receiveData = [receiveData copy];
        _sharedPSC = psc;
        _utcTime = utcTime;
        _formatter = [[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"yyyy-MM-dd"];
        
    }
    return self;
}

- (void)main
{
    _managerObjectContext = [[NSManagedObjectContext alloc]init];
    _managerObjectContext.persistentStoreCoordinator = _sharedPSC;
    Byte cValue[100] = {0};
    [_receiveData getBytes:&cValue length:_receiveData.length];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:_managerObjectContext];
    
    NSDate *historyDate = [NSDate dateWithTimeIntervalSince1970:_utcTime];
    NSString *historyDateString = [_formatter stringFromDate:historyDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", historyDateString];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"utcTime" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *queryError = nil;
    NSArray *fetchedObjects = [_managerObjectContext executeFetchRequest:fetchRequest error:&queryError];
    History *historyObject = nil;
    if (fetchedObjects.count > 0)
    {
        historyObject = [fetchedObjects objectAtIndex:0];
    }
    else
    {
        // 没有查询到记录，插入新对象
        historyObject = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:_managerObjectContext];
        historyObject.utcTime = [_formatter stringFromDate:historyDate];
    }
    
    if (historyObject == nil)
    {
        DEBUG_STR(@"--[%s]-- NULL historyObject-",__FUNCTION__);
        return;
    }
    
    NSEntityDescription *sleepDataEntity = [NSEntityDescription entityForName:@"SleepDataRecord" inManagedObjectContext:_managerObjectContext];
    NSFetchRequest *sleepfetchRequest = [[NSFetchRequest alloc] init];
    sleepfetchRequest.entity = sleepDataEntity;
    if (cValue[1] ==  0x01)
    {
        _utcTime = (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
        for (int i = 6; i < _receiveData.length -1; i+= 1)
        {
            SleepDataRecord *sleepData = [[SleepDataRecord alloc]initWithEntity:sleepDataEntity insertIntoManagedObjectContext:_managerObjectContext];
            sleepData.sleepData = [NSNumber numberWithInt:cValue[i]];
            sleepData.utcTime = [NSDate dateWithTimeIntervalSince1970:_utcTime ];
            sleepData.history = historyObject;
            sleepfetchRequest.predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", sleepData.utcTime];
            NSArray *fetchedItems = [_managerObjectContext executeFetchRequest:sleepfetchRequest error:&queryError];
            if (fetchedItems.count == 0)
            {
                NSSet *sleepDataSet = [NSSet setWithObject:sleepData];
                [historyObject addSleepDataRecordObject:sleepData];
                [historyObject addSleepDataRecord:sleepDataSet];
                
                [_managerObjectContext insertObject:sleepData];
                _utcTime += 5*60*60;
            }
        }
    }
    
    if (cValue[1] == 0x02)
    {
        for (int i = 2; i< _receiveData.length-1 ; i+=1)
        {
            SleepDataRecord *sleepData = [[SleepDataRecord alloc]initWithEntity:sleepDataEntity insertIntoManagedObjectContext:_managerObjectContext];
            sleepData.sleepData = [NSNumber numberWithInt:cValue[i]];
            sleepData.utcTime = [NSDate dateWithTimeIntervalSince1970:_utcTime];
            sleepData.history = historyObject;
            sleepfetchRequest.predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", sleepData.utcTime];
            NSArray *fetchedItems = [_managerObjectContext executeFetchRequest:sleepfetchRequest error:&queryError];
            if (fetchedItems.count == 0)
            {
                NSSet *sleepDataSet = [NSSet setWithObject:sleepData];
                [historyObject addSleepDataRecordObject:sleepData];
                [historyObject addSleepDataRecord:sleepDataSet];
                
                [_managerObjectContext insertObject:sleepData];
                _utcTime += 5*60*60;
            }
        }
    }
    
    NSError *error = nil;
    if (![_managerObjectContext save:&error])
    {
        DEBUG_METHOD(@"【%s】保存sleepData错误：%@",__FUNCTION__,[error localizedDescription]);
    }
}

@end
