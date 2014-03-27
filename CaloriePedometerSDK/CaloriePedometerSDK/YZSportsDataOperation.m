//
//  YZSportsDataOperation.m
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-3-26.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "YZSportsDataOperation.h"
#import "History.h"
#import "PacketsRecord.h"


@interface YZSportsDataOperation()
@property (nonatomic, strong) NSPersistentStoreCoordinator *sharedPSC;
@property (nonatomic, strong) NSManagedObjectContext *managerObjectContext;
@property (nonatomic,   copy) NSData *receiveData;
@property (nonatomic, assign) UInt32 utcTime;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end


@implementation YZSportsDataOperation
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

    NSEntityDescription *sportEntity = [NSEntityDescription entityForName:@"PacketsRecord" inManagedObjectContext:_managerObjectContext];
    NSFetchRequest *sportfetchRequest = [[NSFetchRequest alloc] init];
    sportfetchRequest.entity = sportEntity;
    
    // 第一包睡眠数据
    if (cValue[1] ==  0x01)
    {
        _utcTime = (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
        for (int i = 6; i < _receiveData.length -1; i+=2)
        {
            NSDate *utcDate = [NSDate dateWithTimeIntervalSince1970:_utcTime];
            sportfetchRequest.predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", utcDate];
            NSArray *fetchedItems = [_managerObjectContext executeFetchRequest:sportfetchRequest error:&queryError];
            if (fetchedItems.count == 0)
            {
                PacketsRecord *packets = [[PacketsRecord alloc]initWithEntity:sportEntity insertIntoManagedObjectContext:_managerObjectContext];
                packets.history = historyObject;
                packets.utcTime = [NSDate dateWithTimeIntervalSince1970:_utcTime ];
                packets.stepCount = [NSNumber numberWithInt:cValue[i]];
                if ( i + 1 < _receiveData.length-1 )
                {
                    packets.calorieCount = [NSNumber numberWithInt:cValue[i+1]];
                }

                NSSet *packetSet = [NSSet setWithObject:packets];
                [historyObject addPacketsRecordObject:packets];
                [historyObject addPacketsRecord:packetSet];
                
                [_managerObjectContext insertObject:packets];
                _utcTime += 60*60;
                DEBUG_METHOD(@"-[%s]--插入新的对象0xd1-%d",__FUNCTION__,cValue[i]);
            }
        }
    }
    // 第二包睡眠数据
    if (cValue[1] == 0x02)
    {
        NSDate *utcDate = [NSDate dateWithTimeIntervalSince1970:_utcTime];
        sportfetchRequest.predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", utcDate];
        NSArray *fetchedItems = [_managerObjectContext executeFetchRequest:sportfetchRequest error:&queryError];
        if (fetchedItems.count > 0)
        {
            DEBUG_METHOD(@"-[%s]--找到对象0xd2-",__FUNCTION__);
            PacketsRecord *packets = (PacketsRecord*)[fetchedItems objectAtIndex:0];
            packets.calorieCount = [NSNumber numberWithInt:cValue[2]];
        }
        
        for (int i = 3; i< _receiveData.length-1 ; i+=2)
        {
            _utcTime += 60*60;
            NSDate *utcDate = [NSDate dateWithTimeIntervalSince1970:_utcTime];
            sportfetchRequest.predicate = [NSPredicate predicateWithFormat:@"utcTime = %@", utcDate];
            NSArray *fetchedItems = [_managerObjectContext executeFetchRequest:sportfetchRequest error:&queryError];
            if (fetchedItems.count == 0)
            {
                DEBUG_METHOD(@"-[%s]--插入新的对象0xd2-%d",__FUNCTION__,cValue[i]);
                PacketsRecord *packets = [[PacketsRecord alloc]initWithEntity:sportEntity insertIntoManagedObjectContext:_managerObjectContext];
                packets.history = historyObject;
                packets.utcTime = [NSDate dateWithTimeIntervalSince1970:_utcTime ];
                packets.stepCount = [NSNumber numberWithInt:cValue[i]];
                if ( i + 1 < _receiveData.length-1 )
                {
                    packets.calorieCount = [NSNumber numberWithInt:cValue[i+1]];
                }
                NSSet *packetSet = [NSSet setWithObject:packets];
                [historyObject addPacketsRecordObject:packets];
                [historyObject addPacketsRecord:packetSet];
                
                [_managerObjectContext insertObject:packets];
                
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
