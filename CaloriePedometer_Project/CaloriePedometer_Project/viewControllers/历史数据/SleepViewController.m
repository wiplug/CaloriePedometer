//
//  SleepViewController.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-19.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SleepViewController.h"

@interface SleepViewController ()

@end

@implementation SleepViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"睡眠记录";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    UIView *contentView = [[UIView alloc]initWithFrame:frame];
    contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern_bg_Image"]];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
