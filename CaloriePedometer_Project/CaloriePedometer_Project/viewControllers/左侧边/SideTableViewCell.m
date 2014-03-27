//
//  SideTableViewCell.m
//  CaloriePedometer_Project
//
//  Created by 马远征 on 14-3-4.
//  Copyright (c) 2014年 马远征. All rights reserved.
//

#import "SideTableViewCell.h"

@implementation SideTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIImage *selectedImage = [UIImage imageNamed:@"cell_selected_bg_image"];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:selectedImage];
        self.selectedBackgroundView = imageView;
        self.backgroundColor = [UIColor clearColor];
        
        self.textLabel.textColor = UIColorFromRGB(0xFFFFFF);
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    }
    return self;
}

@end
