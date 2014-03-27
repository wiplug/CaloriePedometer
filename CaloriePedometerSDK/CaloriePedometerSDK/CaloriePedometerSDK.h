//
//  CaloriePedometerSDK.h
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataManager.h"

#define EVENT_UPDATE_PROFILE_NOTIFY @"EVENT_UPDATE_PROFILE_NOTIFY"

typedef NS_ENUM(NSInteger, connectStatus)
{
    connectStatusNoOperate = 0,
    connectStatusSearching,
    connectStatusFoundPeripheral,
    connectStatusConnectOk,
    connectStatusConnectFailed,
    connectStatusTransferring,
    connectStatusTransferComplete,
    connectStatusDisConnect,
    
};

typedef  void (^resultBlock)(UInt32 utcTime, UInt32 steps,Float32 distance, Float32 calories);
typedef void (^finishBlock)(connectStatus status);


@interface CaloriePedometerSDK : NSObject
+ (CaloriePedometerSDK*)sharedInstance;
- (void)startScanning:(resultBlock)block finish:(finishBlock)finishBlock;
- (void)stopScanning;
@end
