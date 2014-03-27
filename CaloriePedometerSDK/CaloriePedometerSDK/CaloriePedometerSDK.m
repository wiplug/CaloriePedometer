//
//  CaloriePedometerSDK.m
//  CaloriePedometerSDK
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CaloriePedometerSDK.h"
#import "CoreDataManager.h"

#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kServiceUUID = @"FC00";
static NSString * const kReadCharacteristicUUID = @"FC20";
static NSString * const kWriteCharacteristicUUID = @"FC21";

static int steps_count = 0;
static int carolies_count = 0;

@interface CaloriePedometerSDK() <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBCharacteristic *writeCharacteristic;
}
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *servicePeripheral;
@property (nonatomic, copy) resultBlock block;
@property (nonatomic, copy) finishBlock finishBlock;
@property (nonatomic, assign) UInt32 sportsDataUtcTime;
@property (nonatomic, assign) UInt32 sleepDataUtcTime;
@end

@implementation CaloriePedometerSDK

+ (CaloriePedometerSDK*)sharedInstance
{
    static dispatch_once_t pred;
    static CaloriePedometerSDK *sharedinstance = nil;
    dispatch_once(&pred, ^{ sharedinstance = [[self alloc] init]; });
    return sharedinstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self
                                                              queue:nil];
    }
    return self;
}

#pragma mark -
#pragma mark CBCentralManagerDelegate

- (void)startScanning:(resultBlock)block finish:(finishBlock)finishBlock;
{
    _block = block;
    _finishBlock = finishBlock;
    if (_finishBlock)
    {
        _finishBlock(connectStatusSearching);
    }
    [_centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:kServiceUUID]]
                                            options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void) stopScanning
{
	[_centralManager stopScan];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        DEBUG_STR(@"Central Manager did change state");
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        DEBUG_STR(@"蓝牙设备可以使用");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    NSString *UUID1 = CFBridgingRelease(CFUUIDCreateString(NULL, peripheral.UUID));
    DEBUG_STR(@"----发现外设----%@",UUID1);
//    [self stopScanning];
    
    if (_servicePeripheral != peripheral)
    {
        _servicePeripheral = peripheral;
        DEBUG_STR(@"Connecting to peripheral %@", peripheral);
        if (_finishBlock)
        {
            _finishBlock(connectStatusFoundPeripheral);
        }
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    DEBUG_STR(@"----成功连接外设----");
    if (_finishBlock)
    {
        _finishBlock(connectStatusConnectOk);
    }
    [_servicePeripheral setDelegate:self];
    [_servicePeripheral discoverServices:@[ [CBUUID UUIDWithString:kServiceUUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DEBUG_STR(@"----连接外设失败----Error:%@",error);
    if (_finishBlock)
    {
        _finishBlock(connectStatusConnectFailed);
    }
    [self cleanup];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    DEBUG_STR(@"-----外设断开连接------%@",error);
    _servicePeripheral = nil;
    if (_finishBlock)
    {
        _finishBlock(connectStatusDisConnect);
    }
    [self cleanup];
}

#pragma mark -
#pragma mark CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    DEBUG_STR(@"----didDiscoverServices----Error:%@",error);
    if (error)
    {
        DEBUG_STR(@"Error discovering service: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in aPeripheral.services)
    {
        DEBUG_STR(@"Service found with UUID: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
        {
            [_servicePeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kReadCharacteristicUUID],[CBUUID UUIDWithString:kWriteCharacteristicUUID]] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        DEBUG_STR(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]])
    {
        for (CBCharacteristic *characteristic in service.characteristics)
        {
            DEBUG_STR(@"----didDiscoverCharacteristicsForService---%@",characteristic);
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
            {
                [peripheral readValueForCharacteristic:characteristic];
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]])
            {
                writeCharacteristic = characteristic;
            }
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        DEBUG_STR(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]] )
    {
        if (characteristic.isNotifying)
        {
            DEBUG_STR(@"Notification began on %@", characteristic);
            [peripheral readValueForCharacteristic:characteristic];
        }
        else
        {
            DEBUG_STR(@"Notification stopped on %@.  Disconnecting", characteristic);
            [_centralManager cancelPeripheralConnection:_servicePeripheral];
            DEBUG_STR(@"------重新启动扫描---");
            if (_finishBlock)
            {
                _finishBlock(connectStatusSearching);
            }
            [_centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:kServiceUUID]]
                                                    options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
    }
}

- (BOOL)resultOfCheckSum:(NSData*)data
{
    NSUInteger length = data.length;
    Byte value[100] = {0};
    [data getBytes:&value length:length];
    
    unsigned long checkSum = 0;
    for (int i = 0; i < length-1; i++)
    {
        checkSum += value[i];
    }
    
    if ((checkSum & 0xFF) == value[length-1])
    {
        return YES;
    }
    return NO;
}

- (BOOL)resultOfCheckSum:(Byte*)receiveBytes length:(NSUInteger)length
{
    unsigned long checkSum = 0;
    for (int i = 0; i < length-1; i++)
    {
        checkSum += receiveBytes[i];
    }
    
    if ((checkSum & 0xFF) == receiveBytes[length-1])
    {
        return YES;
    }
    return NO;
}


- (void)analysisStepsAndCaloriesData:(NSData*)data
{
    NSUInteger length = data.length;
    Byte value[100] = {0};
    [data getBytes:&value length:length];
    if (value[1] == 0x01)
    {
        for (int i = 6; i< length-1 ; i+=2)
        {
            steps_count = steps_count + value[i];
            if ( i + 1 < length-1 )
            {
                carolies_count = carolies_count + value[i+1];
            }
        }
        DEBUG_METHOD(@"-----0x01--step/calories:(%d:%d)",steps_count,carolies_count);
    }
    
    if ( value[1] == 0x02 )
    {
        for (int i = 2; i< length-1 ; i+=2)
        {
            carolies_count = carolies_count + value[i];
            if ( i + 1 < length-1 )
            {
                steps_count = steps_count + value[i+1];
            }
        }
        DEBUG_METHOD(@"-----0x02--step/calories:(%d:%d)",steps_count,carolies_count);
    }
}

- (void)writeResponse:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral byte:(Byte)byte
{
    if (characteristic && peripheral)
    {
        Byte ACkValue[3] = {0};
        ACkValue[0] = 0xe0; ACkValue[1] = byte; ACkValue[2] = ACkValue[0] + ACkValue[1];
        NSData *data = [NSData dataWithBytes:&ACkValue length:sizeof(ACkValue)];
        [peripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (_finishBlock)
    {
        _finishBlock(connectStatusTransferring);
    }

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
    {
        Byte cValue[100] = {0};
        NSData *data = characteristic.value;
        [data getBytes:&cValue length:data.length];
        
        /* Packet for inquire user info*/
        if( cValue[0] == 0xd1 )
        {
            DEBUG_METHOD(@"--0xd1--Packet for inquire user info---");
            if ( ![self resultOfCheckSum:cValue length:data.length] )
            {
                DEBUG_STR(@"----【%s】-0xd1-检验和出错----",__FUNCTION__);
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x01];
            }
            else
            {
                UInt32 weight = (cValue[7] << 8)  + cValue[8];
                int age = cValue[9];
                int height = cValue[10];
                int stride = cValue[11];
                int sex = cValue[12];
                UInt32 stepTarget = (cValue[13]<<16)  + (cValue[14]<<8) + cValue[15];

                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSMutableDictionary *dictionary = [userDefaults objectForKey:@"BLeUserInfo"];
                if (dictionary == nil)
                {
                    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionary];
                    [tmpDic setObject:[NSNumber numberWithUnsignedLong:weight] forKey:@"weight"];
                    [tmpDic setObject:[NSNumber numberWithInt:age] forKey:@"age"];
                    [tmpDic setObject:[NSNumber numberWithInt:height] forKey:@"height"];
                    [tmpDic setObject:[NSNumber numberWithInt:stride] forKey:@"stride"];
                    [tmpDic setObject:[NSNumber numberWithInt:sex] forKey:@"sex"];
                    [tmpDic setObject:[NSNumber numberWithUnsignedLong:stepTarget] forKey:@"stepTarget"];
                    
                    [userDefaults setObject:tmpDic forKey:@"BLeUserInfo"];
                    [userDefaults synchronize];
                    // 更新用户信息
                    [[NSNotificationCenter defaultCenter]postNotificationName:EVENT_UPDATE_PROFILE_NOTIFY object:nil];
                }
                else
                {
                    UInt32 BWeight = (UInt32)[[dictionary objectForKey:@"weight"]unsignedLongValue];
                    int BAge = [[dictionary objectForKey:@"age"]intValue];
                    int BHeight = [[dictionary objectForKey:@"height"]intValue];
                    int BStride = [[dictionary objectForKey:@"stride"]intValue];
                    int BSex = [[dictionary objectForKey:@"sex"]intValue];
                    UInt32 BStepTarget = (UInt32)[[dictionary objectForKey:@"stepTarget"]unsignedLongValue];
                    
                    //如果用户信息与app用户信息不一致，则更新，一致回复成功
                    if (BWeight == weight && BHeight == height && BStride == stride
                        && BSex == sex && BStepTarget == stepTarget)
                    {
                        DEBUG_METHOD(@"-----不需要更新用户信息----");
                        [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x00];
                    }
                    else
                    {
                        DEBUG_METHOD(@"-----同步更新用户信息----");
                        Byte ACKValue[11] = {0};
                        ACKValue[0] = 0xe1;
                        ACKValue[1] = (BWeight >> 8) & 0xFF;
                        ACKValue[2] = BWeight & 0xFF;
                        ACKValue[3] = BAge;
                        ACKValue[4] = BHeight;
                        ACKValue[5] = BStride;
                        ACKValue[6] = BSex;
                        ACKValue[7] = (BStepTarget >> 16) & 0xFF;
                        ACKValue[8] = (BStepTarget >> 8) & 0xFF;
                        ACKValue[9] = BStepTarget & 0xFF;
                        ACKValue[10] = (ACKValue[0] + ACKValue[1] + ACKValue[2] + ACKValue[3] + ACKValue[4] + ACKValue[5] +ACKValue[6] + ACKValue[7] + ACKValue[8] + ACKValue[9]) & 0xFF;
                        
                        NSData *data = [NSData dataWithBytes:&ACKValue length:sizeof(ACKValue)];
                        [peripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
                    }
                }
                DEBUG_METHOD(@"-----{\n weight:%u \n age:%d \n height:%d \n stride:%d \n sex:%d \n stepTarget:%u \n}",(unsigned int)weight,age,height,stride,sex,(unsigned int)stepTarget);
            }
        }
        
        /* Packet for asking or UTC sync*/
        if( cValue[0] == 0xd2 )
        {
            DEBUG_METHOD(@"--0xd2--Packet for asking or UTC sync----");
            
            if ( ![self resultOfCheckSum:characteristic.value] )
            {
                DEBUG_STR(@"----【%s】-0xd2-检验和出错----",__FUNCTION__);
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x01];
            }
            else
            {
                // 更新UTC时间
                NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
                NSTimeZone *zone = [NSTimeZone systemTimeZone];
                NSInteger interval = [zone secondsFromGMTForDate:datenow];
                NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
                DEBUG_METHOD(@"----localeDate----%@",localeDate);
                NSTimeInterval timeStamp = [localeDate timeIntervalSince1970];
                UInt32 dTime = (UInt32)timeStamp;
                
                Byte ACKValue[6] = {0};
                ACKValue[0] = 0xe2;
                ACKValue[1] = (dTime >> 24) & 0xFF;
                ACKValue[2] = (dTime >> 16) & 0xFF;
                ACKValue[3] = (dTime >> 8) & 0XFF;
                ACKValue[4] = dTime & 0xFF;
                ACKValue[5] = (ACKValue[0] + ACKValue[1] + ACKValue[2] + ACKValue[3] + ACKValue[4]) & 0xFF;
                NSData *data = [NSData dataWithBytes:&ACKValue length:sizeof(ACKValue)];
                [peripheral writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
            }
        }
        
        /*Packet for uploading time and date last sync and total steps and calories since
         last sync.*/
        if (cValue[0] == 0xd3)
        {
            DEBUG_METHOD(@"--0xd3--Packet for asking or UTC sync----");
            if ( ![self resultOfCheckSum:cValue length:data.length])
            {
                DEBUG_STR(@"----【%s】-0xd3-检验和出错----",__FUNCTION__);
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x01];
            }
            else
            {
                UInt32 UTCTime = (cValue[1]<<24) + (cValue[2]<<16) + (cValue[3]<<8) + cValue[4];
                UInt32 steps = (cValue[5]<<16) + (cValue[6]<<8) + cValue[7];
                UInt32 distance = (cValue[8]<<16) +(cValue[9]<<8) + cValue[10];
                UInt32 calorie = (cValue[11]<<16) + (cValue[12]<<8) + cValue[13];
                UInt32 checkSum = cValue[14];
                DEBUG_METHOD(@"------UTC时间---%lu",(unsigned long)UTCTime);
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x00];
                
                NSMutableDictionary *ditionary = [NSMutableDictionary dictionary];
                [ditionary setObject:[NSNumber numberWithUnsignedLong:UTCTime] forKey:@"UTCTime"];
                [ditionary setObject:[NSNumber numberWithUnsignedLong:steps] forKey:@"steps"];
                [ditionary setObject:[NSNumber numberWithUnsignedLong:distance] forKey:@"distance"];
                [ditionary setObject:[NSNumber numberWithUnsignedLong:calorie] forKey:@"calorie"];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:ditionary forKey:@"lastSyncPacket"];
                [userDefaults synchronize];
                
                if (_block)
                {
                    _block(UTCTime,steps,distance,calorie);
                }
                
                [[CoreDataManager sharedInstance]insertNewSyncObject:UTCTime steps:steps calories:calorie distance:distance];
                
                DEBUG_METHOD(@"-----{\n steps:%u \n distance:%u \n calorie:%u \n checkSum:%u \n }",(unsigned int)steps,(unsigned int)distance,(unsigned int)calorie,(unsigned int)checkSum);
            }
        }
        
        /* Packets for every 15 min(maximun)*/
        if( cValue[0] == 0xd4 )
        {
            DEBUG_METHOD(@"--0xd4--Packets for every 15 min(maximun)----%@",characteristic.value);
            if ( ![self resultOfCheckSum:cValue length:data.length] )
            {
                DEBUG_STR(@"----【%s】-0xd4-检验和出错----",__FUNCTION__);
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x01];
            }
            else
            {
                if (cValue[1] == 0x03)
                {
                    [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x00];
                }
                if (cValue[1] == 0x01 || cValue[1] == 0x02 )
                {
                    if ( cValue[1] == 0x01)
                    {
                        _sportsDataUtcTime =  (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
                    }
                    
                    if ( cValue[1] == 0x02 )
                    {
                        _sportsDataUtcTime += 6*60*60;
                    }
                    [[CoreDataManager sharedInstance]insertNewSportData:characteristic.value utcTime:_sportsDataUtcTime];
                }
            }
        }
        
        /* Packet for sleeping data*/
        if( cValue[0] == 0xd5 )
        {
            DEBUG_METHOD(@"--0xd5---Packet for sleeping data----");
            if ( ![self resultOfCheckSum:cValue length:data.length])
            {
                DEBUG_STR(@"----【%s】-0xd5-检验和出错----",__FUNCTION__);
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x01];
            }
            else
            {
                
                if (cValue[1] == 0x03)
                {
                    [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x00];
                }
                
                if (cValue[1] == 0x01 || cValue[1] == 0x02 )
                {
                    if ( cValue[1] == 0x01)
                    {
                        _sleepDataUtcTime =  (cValue[2]<<24) + (cValue[3]<<16) + (cValue[4]<<8) + cValue[5];
                    }
                    
                    if ( cValue[1] == 0x02 )
                    {
                        _sleepDataUtcTime += 13*5*60*60;
                    }
                    [[CoreDataManager sharedInstance]insertNewSleepData:characteristic.value utcTime:_sleepDataUtcTime];
                }
            }
        }
        
        /* Transfer Complete,the iphone app can disconnect from bracelet*/
        if( cValue[0] == 0xd6 )
        {
            if ( [self resultOfCheckSum:cValue length:data.length])
            {
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x00];
            }
            else
            {
                [self writeResponse:writeCharacteristic peripheral:peripheral byte:0x01];
            }
            
            if (_finishBlock)
            {
                _finishBlock(connectStatusTransferComplete);
            }
            
            [self cleanup];
            
            if (_finishBlock)
            {
                _finishBlock(connectStatusDisConnect);
            }
        }//if
    }
}

- (void)cleanup
{
    if (!_servicePeripheral.isConnected)
    {
        return;
    }
    
    if (_servicePeripheral.services != nil)
    {
        for (CBService *service in _servicePeripheral.services)
        {
            if (service.characteristics != nil)
            {
                for (CBCharacteristic *characteristic in service.characteristics)
                {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]])
                    {
                        if (characteristic.isNotifying)
                        {
                            [_servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }//for
            }
        }//for
    }
    
    [_centralManager cancelPeripheralConnection:_servicePeripheral];
    DEBUG_METHOD(@"------重新启动扫描---");
    if (_finishBlock)
    {
        _finishBlock(connectStatusSearching);
    }
    [_centralManager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:kServiceUUID]]
                                            options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

@end
