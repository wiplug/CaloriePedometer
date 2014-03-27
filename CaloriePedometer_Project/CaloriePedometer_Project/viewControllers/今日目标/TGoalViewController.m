//
//  TGoalViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-6.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "TGoalViewController.h"

@interface TGoalViewController ()

@end

@implementation TGoalViewController

#pragma mark -
#pragma mark dealloc

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"今日目标";
    }
    return self;
}

#pragma mark -
#pragma mark loadView

- (void)loadView
{
    [super loadView];
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIView *contentView = [[UIView alloc]initWithFrame:frame];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}



@end
