//
//  YZSportsDataOperation.h
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-3-26.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface YZSportsDataOperation : NSOperation
- (id)initWithData:(NSData*)receiveData utcTime:(UInt32)utcTime sharedPSC:(NSPersistentStoreCoordinator*)psc;
@end
