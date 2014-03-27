//
//  PLActionSheet.h
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completeBlock)(NSInteger result);

@interface PLActionSheet : UIView
- (id)initWithTitle:(NSString*)title Unit:(NSString*)uint Parmas:(NSArray*)parmas;
- (void)show:(completeBlock)block;
@end
