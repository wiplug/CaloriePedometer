//
//  SportsRecordTableViewCell.h
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-19.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaloriesOrDistanceView.h"

@interface SportsStepsView : UIView
@property (nonatomic, assign) UInt32 value;
@end

@interface SportsRecordTableViewCell : UITableViewCell
@property (nonatomic, strong, readonly) CaloriesOrDistanceView *caloriesView;
@property (nonatomic, strong, readonly) CaloriesOrDistanceView *distanceView;
@property (nonatomic, strong, readonly) SportsStepsView *sportsStepsView;
@end
