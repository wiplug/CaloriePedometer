//
//  CaloriesOrDistanceView.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-2-28.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "CaloriesOrDistanceView.h"

@implementation CaloriesOrDistanceView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setValue:(CGFloat)Value
{
    if (_Value != Value)
    {
        _Value = Value;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_iconImage)
    {
        CGSize size = _iconImage.size;
        CGRect imageRect = CGRectMake(20, (rect.size.height - size.height)*0.5, 23, size.height);
        [_iconImage drawInRect:imageRect];
    }
    
    if ( _textColor)
    {
        [_textColor setFill];
        NSString *valueString = [NSString stringWithFormat:@"%.1f",_Value];
        if (valueString)
        {
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
            CGRect Rect = CGRectMake(65, 5, 80, 24);
            [valueString drawInRect:Rect withFont:font];
        }
        if (_targetTitle)
        {
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
            CGRect Rect = CGRectMake(60, 30, 100, 24);
            [_targetTitle drawInRect:Rect withFont:font];
        }
    }
}


@end
