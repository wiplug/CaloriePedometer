//
//  PLActionSheet.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "PLActionSheet.h"
@interface PLActionSheet() < UITableViewDataSource, UITableViewDelegate >
@property (nonatomic, strong) NSArray *paramsArray;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titlelabel;
@property (nonatomic ,strong) completeBlock block;
@property (nonatomic, strong) NSString *unit;
@end

@implementation PLActionSheet

- (id)initWithTitle:(NSString*)title Unit:(NSString*)unit Parmas:(NSArray*)parmas
{
    CGRect bounds = [[UIScreen mainScreen]bounds];
    self = [super initWithFrame:bounds];
    if (self)
    {
        _paramsArray = parmas;
        _title = title;
        _unit = unit;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        [self setUp];
    }
    return self;
}

- (CGSize)sizeWithText:(NSString*)text font:(UIFont*)font width:(CGFloat)witdh
{
    if (text)
    {
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(witdh, CGFLOAT_MAX)
                           lineBreakMode:(unsigned)NSLineBreakByWordWrapping];
        return size;
    }
    return CGSizeZero;
}

- (void)setUp
{
    UIImage *bgImage = [UIImage imageNamed:@"pb_actionsheet_bg_image"];
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:frame];
    bgImageView.image = bgImage;
    [self addSubview:bgImageView];
    
    CGFloat contentheight = 320;
    CGFloat originY = 20;
    if (_title)
    {
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        CGSize titleSize = [self sizeWithText:_title font:titleFont width:KScreenWidth - 20];
        CGFloat height = (titleSize.height < 24 ? 24 : titleSize.height);
        _titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, KScreenWidth-20, 24)];
        [_titlelabel setBackgroundColor:[UIColor clearColor]];
        [_titlelabel setTextColor:[UIColor blackColor]];
        [_titlelabel setTextAlignment:(unsigned)NSTextAlignmentCenter];
        [_titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [_titlelabel setNumberOfLines:2];
        [_titlelabel setLineBreakMode:(unsigned)NSLineBreakByWordWrapping];
        [_titlelabel setText:_title];
        contentheight += height+20;
        originY += height;
    }
    
    CGRect contentFrame = CGRectMake(0, KScreenHeight, KScreenWidth, contentheight);
    _contentView = [[UIView alloc]initWithFrame:contentFrame];
    [_contentView setBackgroundColor:[UIColor colorWithRed:0.937 green:0.933 blue:0.929 alpha:1.0]];
    [_contentView addSubview:_titlelabel];
    [self addSubview:_contentView];
    
    CGRect tableframe = CGRectMake(20, originY, KScreenWidth - 40, contentFrame.size.height - originY);
    _tableView = [[UITableView alloc]initWithFrame:tableframe];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_contentView addSubview:_tableView];
}

- (void)show:(completeBlock)block
{
    _block = block;
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self];
    [self MoveIn];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [touches anyObject];
    if ([myTouch.view isEqual:self])
    {
        [self MoveOut];
    }
}


- (void)MoveIn
{
    [UIView animateWithDuration:0.35f
                     animations:^{
                         CGRect frame = _contentView.frame;
                         frame.origin.y = KScreenHeight - frame.size.height;
                         _contentView.frame = frame;
                     }
                     completion:^(BOOL finished){}];
}

- (void)MoveOut
{
    [UIView animateWithDuration:0.25f
                     animations:^{
                         CGRect frame = _contentView.frame;
                         frame.origin.y = KScreenHeight;
                         _contentView.frame = frame;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _paramsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *string = [_paramsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",string,_unit];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *string = [_paramsArray objectAtIndex:indexPath.row];
    _block([string intValue]);
    [self MoveOut];
}

@end
