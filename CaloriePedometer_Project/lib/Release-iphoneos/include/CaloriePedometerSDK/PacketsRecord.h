//
//  PacketsRecord.h
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-3-12.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PacketsRecord : NSManagedObject

@property (nonatomic, retain) NSDate * utcTime;
@property (nonatomic, retain) NSNumber * stepCount;
@property (nonatomic, retain) NSNumber * calorieCount;
@property (nonatomic, retain) NSManagedObject *history;

@end
