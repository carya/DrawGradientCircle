//
//  GradualSlider.h
//
//  Created by MaohuaLiu on 14-10-14.
//  Copyright (c) 2014年 readus.org. All rights reserved.

//

#import <UIKit/UIKit.h>

#define LS_SLIDER_SIZE    280

@interface GradualSlider : UIControl

@property (nonatomic, strong) UIColor *handleFillColor;
@property (nonatomic, assign) CGFloat currentValue;

@end
