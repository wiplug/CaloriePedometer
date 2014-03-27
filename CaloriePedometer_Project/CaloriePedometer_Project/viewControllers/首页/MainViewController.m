//
//  MainViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "MainViewController.h"
#import "GoalsAndHistoryView.h"
#import "CaloriesOrDistanceView.h"
#import "HomeStepsView.h"

#import <CaloriePedometerSDK/CaloriePedometerSDK.h>

@interface MainViewController ()
{
    GoalsAndHistoryView *_ghView;
    CaloriesOrDistanceView *_caloriesView;
    CaloriesOrDistanceView *_distanceView;
    HomeStepsView *_stepView;
    UILabel *_statuslabel;
    UILabel *_lastSyncTimelabel;
    
    NSDateFormatter *_dateFormatter;
}
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@end

@implementation MainViewController

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{

}

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
        self.title = @"周三 2月26";
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

- (void)initBarButton
{
    UIImage *image = [UIImage imageNamed:@"home_left_btn_image"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(20, 0, 43.5, 15.5)];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(clickRightButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
}

- (void)initContentBgView
{
    UIImage *bgImage = [UIImage imageNamed:@"home_content_bg_image"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:160 topCapHeight:300];
    CGRect frame = [[UIScreen mainScreen]bounds];
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:bgImage];
    [bgImageView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 64)];
    [self.view addSubview:bgImageView];
}

- (void)initMarkView
{
    UIImage *markImage = [UIImage imageNamed:@"home_mark_image"];
    UIImageView *markImageView = [[UIImageView alloc]initWithImage:markImage];
    [markImageView setFrame:CGRectMake(271, 0, 39, 41.5)];
    [self.view addSubview:markImageView];
}

- (void)initConnectDeviceBtn
{
    UIImage *btnImage = [UIImage imageNamed:@"home_connect_btn_image"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:btnImage forState:UIControlStateNormal];
    [button setFrame:CGRectMake((KScreenWidth - 224.5)*0.5, 120, 224.5, 40)];
    [button setTitle:@"连接设备" forState:UIControlStateNormal];
    [button setTitle:@"连接设备" forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(clickToConnectDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)initTargetValueView
{
    
    CGRect step = CGRectMake(20,60, KScreenWidth, 80);
    _stepView = [[HomeStepsView alloc]initWithFrame:step];
    if (_dictionary)
    {
        _stepView.value = (UInt32)[[_dictionary objectForKey:@"steps"]unsignedLongValue];
    }
    
    [self.view addSubview:_stepView];
    
    CGRect distance = CGRectMake(0, 180, KScreenWidth*0.5, 60);
    _distanceView = [[CaloriesOrDistanceView alloc]initWithFrame:distance];
    _distanceView.textColor = UIColorFromRGB(0x000000);
    _distanceView.targetTitle = @"距离 (m)";
    _distanceView.iconImage = [UIImage imageNamed:@"home_distance_image"];
    if (_dictionary)
    {
        Float32 distance = [[_dictionary objectForKey:@"distance"]unsignedLongValue];
        _distanceView.Value = distance/100;
    }
    [self.view addSubview:_distanceView];
    
    CGRect calories = CGRectMake(KScreenWidth*0.5, 180, KScreenWidth*0.5, 60);
    _caloriesView = [[CaloriesOrDistanceView alloc]initWithFrame:calories];
    _caloriesView.textColor = UIColorFromRGB(0xD53328);
    _caloriesView.targetTitle = @"卡路 (kcal)";
    _caloriesView.iconImage = [UIImage imageNamed:@"home_carolies_image"];
    if (_dictionary)
    {
        Float32 calorie = [[_dictionary objectForKey:@"calorie"]unsignedLongValue];
        _caloriesView.Value = calorie/10;
    }
    [self.view addSubview:_caloriesView];
}

- (void)initCopyRightView
{
    UILabel *label = [[UILabel alloc]init];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFrame:CGRectMake(0, KScreenHeight - 64 - 30, KScreenWidth, 24)];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue" size:12.0]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:UIColorFromRGB(0xADADAD)];
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, 1.0)];
    [label setText:@"ShenZhen Mcking Healthy Electronic Co.,Ltd."];
    [self.view addSubview:label];
}

- (void)initBoxImageView
{
    CGRect frame = CGRectMake(KScreenWidth*0.5 - 150, 245, 300, 120);
    _ghView = [[GoalsAndHistoryView alloc]initWithFrame:frame];
    if (_dictionary)
    {
        UInt32 steps = (UInt32)[[_dictionary objectForKey:@"steps"]unsignedLongValue];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dictionary = [userDefaults objectForKey:@"BLeUserInfo"];
        UInt32 BStepTarget = 10000;
        if (dictionary)
        {
            BStepTarget = (UInt32)[[dictionary objectForKey:@"stepTarget"]unsignedLongValue];
            UInt32 result = (BStepTarget - steps > 0) ? (BStepTarget - steps) : 0;
            [_ghView setGoalsSteps:result];
        }
    }
    [_ghView setTotalSteps:0];
    [self.view addSubview:_ghView];
}

- (void)initStatuslabel
{
    _statuslabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, KScreenWidth, 24)];
    _statuslabel.backgroundColor = [UIColor clearColor];
    _statuslabel.textAlignment = UITextAlignmentCenter;
    _statuslabel.textColor = [UIColor redColor];
    _statuslabel.text = @"蓝牙设备未连接";
    [self.view addSubview:_statuslabel];
}

- (void)initImageLine
{
    UIImage *horizontalImage = [UIImage imageNamed:@"horizontal_line_image"];
    UIImageView *horizontalImageView = [[UIImageView alloc]initWithImage:horizontalImage];
    [horizontalImageView setFrame:CGRectMake(0, 180, KScreenWidth, 1)];
    [self.view addSubview:horizontalImageView];
    
    UIImage *verticalImage = [UIImage imageNamed:@"vertical_line_image"];
    UIImageView *verticalImageView = [[UIImageView alloc]initWithImage:verticalImage];
    [verticalImageView setFrame:CGRectMake(KScreenWidth*0.5, 180, 1, 62)];
    [self.view addSubview:verticalImageView];
}

- (void)initLastSyncTimeLabel
{
    CGRect frame = CGRectMake(20, 0, 230, 24);
    _lastSyncTimelabel = [[UILabel alloc]initWithFrame:frame];
    _lastSyncTimelabel.backgroundColor = [UIColor clearColor];
    _lastSyncTimelabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    if (_dictionary)
    {
        UInt32 utcTime = (UInt32)[[_dictionary objectForKey:@"UTCTime"]unsignedLongValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcTime];
        if (_dateFormatter == nil)
        {
            _dateFormatter = [[NSDateFormatter alloc] init];
        }
        NSTimeZone *GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [_dateFormatter setTimeZone:GTMzone];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *currentDateStr = [_dateFormatter stringFromDate:date];
        
        _lastSyncTimelabel.text = [NSString stringWithFormat:@"最后同步时间：%@",currentDateStr];
    }
    [self.view addSubview:_lastSyncTimelabel];
}

- (void)loadlastSyncPacket
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *tmpDic = [userDefaults objectForKey:@"lastSyncPacket"];
    self.dictionary = tmpDic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadlastSyncPacket];
    [self initBarButton];
    [self initContentBgView];
    [self initMarkView];
    [self initTargetValueView];
    [self initImageLine];
    [self initCopyRightView];
    [self initBoxImageView];
    [self initStatuslabel];
    [self initLastSyncTimeLabel];
    [self clickToConnectDevice];
    
}

- (void)clickRightButton:(id)sender
{
    
}

- (void)clickToConnectDevice
{
    __block MainViewController *this = self;
    [[CaloriePedometerSDK sharedInstance]startScanning:^(UInt32 utcTime, UInt32 steps, Float32 distance, Float32 calories) {
        
        // 更新最后同步时间
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:utcTime];
        NSTimeZone *GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        if (_dateFormatter == nil)
        {
            _dateFormatter = [[NSDateFormatter alloc] init];
        }
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [_dateFormatter setTimeZone:GTMzone];
        NSString *currentDateStr = [_dateFormatter stringFromDate:date];
        _lastSyncTimelabel.text = [NSString stringWithFormat:@"最后同步时间：%@",currentDateStr];
        
        // 更新最后同步数据
        this->_distanceView.Value = distance/100;
        this->_caloriesView.Value = calories/10;
        this->_stepView.value = steps;
        
        // 就算距离目标距离只差
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dictionary = [userDefaults objectForKey:@"BLeUserInfo"];
        UInt32 BStepTarget = 10000;
        if (dictionary)
        {
            BStepTarget = (UInt32)[[dictionary objectForKey:@"stepTarget"]unsignedLongValue];
            UInt32 result = (BStepTarget - steps > 0) ? (BStepTarget - steps) : 0;
                [this->_ghView setGoalsSteps:result];
        }
        
    } finish:^(connectStatus status) {
        switch (status)
        {
            case connectStatusNoOperate:
            {
                _statuslabel.text = @"蓝牙设备未连接";
            }
                break;
            case connectStatusSearching:
            {
                _statuslabel.text = @"正在搜索蓝牙设备";
            }
                break;
            case connectStatusFoundPeripheral:
            {
                _statuslabel.text = @"发现蓝牙设备";
            }
                break;
            case connectStatusConnectOk:
            {
                _statuslabel.text = @"成功连接蓝牙设备";
            }
                break;
            case connectStatusConnectFailed:
            {
                _statuslabel.text = @"连接蓝牙设备失败";
            }
                break;
            case connectStatusTransferring:
            {
                _statuslabel.text = @"正在读取蓝牙数据";
            }
                break;
            case connectStatusTransferComplete:
            {
                _statuslabel.text = @"完成蓝牙数据读取";
            }
                break;
            case connectStatusDisConnect:
            {
                _statuslabel.text = @"蓝牙设备断开连接";
            }
                break;
            default:
                break;
        }
    }];
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

#ifdef __IPHONE_6_0

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#endif

@end
