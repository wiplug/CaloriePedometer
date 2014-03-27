//
//  ProfileTableViewCell.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-17.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "ProfileTableViewCell.h"

@implementation ProfileTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        self.superview.backgroundColor = [UIColor clearColor];
        
        _contentlabel = [[UILabel alloc]init];
        _contentlabel.backgroundColor = [UIColor clearColor];
        _contentlabel.highlightedTextColor = [UIColor blackColor];
        _contentlabel.textColor = [UIColor blackColor];
        [self addSubview:_contentlabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    CGFloat originX = self.textLabel.frame.origin.x + size.width;
    CGRect frame = CGRectMake(originX + 10, (self.frame.size.height - 24)*0.5, 160, 24);
    _contentlabel.frame = frame;
}

@end
