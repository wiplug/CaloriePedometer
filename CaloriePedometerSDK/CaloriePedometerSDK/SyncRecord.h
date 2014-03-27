//
//  SyncRecord.h
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-3-20.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncRecord : NSManagedObject

@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * steps;
@property (nonatomic, retain) NSString * utcTime;

@end
