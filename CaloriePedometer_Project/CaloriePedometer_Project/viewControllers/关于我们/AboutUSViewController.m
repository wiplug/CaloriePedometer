//
//  AboutUSViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-6.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "AboutUSViewController.h"

@interface AboutUSViewController ()

@end

@implementation AboutUSViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"关于我们";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIView *contentView = [[UIView alloc]initWithFrame:frame];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view = contentView;
}

- (void)initlogoImage
{
    UIImage *image = [UIImage imageNamed:@"logo"];
    UIImageView *logoImageView = [[UIImageView alloc]initWithImage:image];
    logoImageView.frame = CGRectMake(KScreenWidth*0.5 - 48, 20, 96, 96);
    [self.view addSubview:logoImageView];
}

- (void)initTitleLabel
{
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, KScreenWidth, 24)];
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *strAppName = [dicInfo objectForKey:@"CFBundleDisplayName"];
    titlelabel.text = strAppName;
    [self.view addSubview:titlelabel];
}

- (void)initVersionLabel
{
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 160, KScreenWidth, 24)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
//    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
//    NSString *strAppVersion = [dicInfo objectForKey:@"CFBundleShortVersionString"];
//    NSString *strAppBuild = [dicInfo objectForKey:@"CFBundleVersion"];
//    label.text = [NSString stringWithFormat:@"version %@  build %@",strAppVersion,strAppBuild];
//    [self.view addSubview:label];
    
    CGRect frame = CGRectMake(0, 160, KScreenWidth, 400);
    UITextView *textView = [[UITextView alloc]initWithFrame:frame];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setEditable:NO];
    [textView setDataDetectorTypes:UIDataDetectorTypeAll];
    [textView setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setScrollEnabled:NO];
    
    // 获取系统版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *versionText = [NSString stringWithFormat:@"version %@  build %@",appVersion,appBuild];;
    // 服务热线
    NSString *string = [versionText stringByAppendingFormat:@"\n\n"];
    string = [string stringByAppendingString:@"深圳市迈圈健康电子有限公司 版权所有\n\n"];
    string = [string stringByAppendingFormat:@"www.mcking.cn\n\n"];
    string = [string stringByAppendingFormat:@"电话：0755-82419951\n"];
    [textView setText:string];
    [self.view addSubview:textView];
    
}

- (void)initCopyRightlabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, KScreenHeight - 100, KScreenWidth, 24)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Helvetica" size:14];
    label.textColor = UIColorFromRGB(0xA0B4B3);
    label.text = @"Shenzhen Mcking Heathy Electronic Co.,Ltd.";
    [self.view addSubview:label];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initlogoImage];
    [self initTitleLabel];
    [self initVersionLabel];
    [self initCopyRightlabel];
}



@end
