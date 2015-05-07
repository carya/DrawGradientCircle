//
//  ViewController.m
//  DrawGradientCircle
//
//  Created by MaohuaLiu on 15/2/10.
//  Copyright (c) 2015年 MaohuaLiu. All rights reserved.
//

#import "ViewController.h"
#import "GradualSlider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GradualSlider *ls = [[GradualSlider alloc] initWithFrame:CGRectMake(40, 40, LS_SLIDER_SIZE, LS_SLIDER_SIZE)];
    [ls addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:ls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sliderValueChange:(GradualSlider *)ls {
    NSLog(@"LuminanceSlider's current value: %f", ls.currentValue);
}

@end
