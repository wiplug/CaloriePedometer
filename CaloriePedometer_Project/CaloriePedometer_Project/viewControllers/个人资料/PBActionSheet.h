//
//  PBActionSheet.h
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^completeBlock)(NSInteger buttonIndex);

@interface PBActionSheet : UIView
- (id)initWithTitle:(NSString*)title
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show:(completeBlock)block;
@end
