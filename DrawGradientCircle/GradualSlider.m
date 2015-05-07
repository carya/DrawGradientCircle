//
//  GradualSlider.m
//
//  Created by MaohuaLiu on 14-10-14.
//  Copyright (c) 2014年 readus.org. All rights reserved.
//

#import "GradualSlider.h"

#define LS_LINE_WIDTH       2
#define LS_HANDLE_RADIUS     25
#define LS_HANDLE_INNER_RADIUS   10

#define SQR(x)			((x) * (x))
#define DEGREE_TO_RADIAN(degree) (((degree) * M_PI) / 180.0f)
#define RADIAN_TO_DEGREE(radian) (((radian) * 180) / M_PI)

#define CartesianToCompass(rad) ((rad) + M_PI / 2 )
#define CompassToCartesian(rad) ((rad) - M_PI / 2 )

@interface GradualSlider ()

@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) CGFloat radianFromNorth;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat lineWidth;

@property (nonatomic, assign) CGFloat startradianFromNorth;
@property (nonatomic, assign) CGFloat endradianFromNorth;

@property (strong, nonatomic) CALayer *bgLayer;
@property (strong, nonatomic) CALayer *outerCircleLayer;

@end

@implementation GradualSlider

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        
        self.centerPoint = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetWidth(self.bounds)/2);
        
        self.lineWidth = LS_LINE_WIDTH;
        self.radius = LS_SLIDER_SIZE * 0.5 - self.lineWidth * 0.5 - LS_HANDLE_RADIUS;
        self.startradianFromNorth = DEGREE_TO_RADIAN(20);
        self.endradianFromNorth = DEGREE_TO_RADIAN(340);
        self.radianFromNorth = DEGREE_TO_RADIAN(100);
        
        [self drawGradientCircle];
        [self drawHandle];
    }
    
    return self;
}

- (void)drawGradientCircle {
    _bgLayer = [CALayer layer];
    _bgLayer.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds) - LS_HANDLE_RADIUS * 2, CGRectGetHeight(self.bounds) - LS_HANDLE_RADIUS * 2);
    _bgLayer.position = self.centerPoint;
    [self.layer addSublayer:_bgLayer];
    
    CGColorRef topLeftColor = [UIColor blackColor].CGColor;
    CGColorRef bottomColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1].CGColor;
    CGColorRef topRightColor = [UIColor whiteColor].CGColor;
    
    CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
    leftGradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(_bgLayer.bounds)/2, CGRectGetHeight(_bgLayer.bounds));
    leftGradientLayer.colors = @[(__bridge id)topLeftColor, (__bridge id)bottomColor];
    leftGradientLayer.startPoint = CGPointMake(0.5, 0);
    leftGradientLayer.endPoint = CGPointMake(0.5, 1);
    [_bgLayer addSublayer:leftGradientLayer];
    
    CAGradientLayer *rightGradientLayer = [CAGradientLayer layer];
    rightGradientLayer.frame = CGRectMake(CGRectGetWidth(_bgLayer.bounds)/2, 0, CGRectGetWidth(_bgLayer.bounds)/2, CGRectGetHeight(_bgLayer.bounds));
    rightGradientLayer.colors = @[(__bridge id)bottomColor, (__bridge id)topRightColor];
    rightGradientLayer.startPoint = CGPointMake(0.5, 1);
    rightGradientLayer.endPoint = CGPointMake(0.5, 0);
    [_bgLayer addSublayer:rightGradientLayer];
    
    CGPoint circleCenterPoint = CGPointMake(CGRectGetWidth(_bgLayer.bounds)/2, CGRectGetHeight(_bgLayer.bounds)/2);
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.position = circleCenterPoint;
    maskLayer.bounds = _bgLayer.bounds;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.strokeColor = [UIColor redColor].CGColor;
    maskLayer.lineCap = kCALineCapRound;
    maskLayer.lineWidth = self.lineWidth;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:circleCenterPoint radius:self.radius startAngle:CompassToCartesian(self.startradianFromNorth) endAngle:CompassToCartesian(self.endradianFromNorth) clockwise:true];
    maskLayer.path = maskPath.CGPath;
    
    _bgLayer.mask = maskLayer;
}

- (void)drawHandle {
    CGPoint handleCenter = [self pointOnCircleAtRadian:self.radianFromNorth];
    
    _outerCircleLayer = [CALayer layer];
    _outerCircleLayer.bounds = CGRectMake(0, 0, LS_HANDLE_RADIUS * 2, LS_HANDLE_RADIUS * 2);
    _outerCircleLayer.cornerRadius = LS_HANDLE_RADIUS;
    _outerCircleLayer.position = handleCenter;
    _outerCircleLayer.shadowColor = [UIColor grayColor].CGColor;
    _outerCircleLayer.shadowOffset = CGSizeZero;
    _outerCircleLayer.shadowOpacity = 0.7;
    _outerCircleLayer.shadowRadius = 3;
    _outerCircleLayer.borderWidth = 1;
    _outerCircleLayer.borderColor = [UIColor grayColor].CGColor;
    _outerCircleLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:_outerCircleLayer];
    
    CAShapeLayer *innerCircleLayer = [CAShapeLayer layer];
    innerCircleLayer.bounds = CGRectMake(0, 0, LS_HANDLE_INNER_RADIUS * 2, LS_HANDLE_INNER_RADIUS * 2);
    innerCircleLayer.cornerRadius = LS_HANDLE_INNER_RADIUS;
    innerCircleLayer.position = CGPointMake(LS_HANDLE_RADIUS, LS_HANDLE_RADIUS);
    innerCircleLayer.backgroundColor = self.handleFillColor.CGColor;
    innerCircleLayer.borderWidth = 1;
    innerCircleLayer.borderColor = [UIColor grayColor].CGColor;
    [_outerCircleLayer addSublayer:innerCircleLayer];
}

#pragma mark -

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInsideHandle:point withEvent:event]) {
        return YES; // Point is indeed within handle bounds
    } else {
        return [self pointInsideCircle:point withEvent:event]; // Return YES if point is inside slider's circle
    }
}

//检测触摸点是否在slider所在圆圈范围内
- (BOOL)pointInsideCircle:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint p1 = [self centerPoint];
    CGPoint p2 = point;
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    double distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance < self.radius + self.lineWidth * 0.5;
}

//检测触摸点是否在滑动块中
- (BOOL)pointInsideHandle:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    CGPoint handleCenter = [self pointOnCircleAtRadian:self.radianFromNorth];
    CGFloat handleRadius = MAX(LS_HANDLE_RADIUS * 2, 44.0) * 0.5;
    // Adhere to apple's design guidelines - avoid making touch targets smaller than 44 points
    
    // Treat handle as a box around it's center
    CGRect handleRect = CGRectMake(handleCenter.x - handleRadius, handleCenter.y - handleRadius, handleRadius * 2, handleRadius * 2);
    return CGRectContainsPoint(handleRect, point);
}

- (CGPoint)pointOnCircleAtRadian:(CGFloat)radian {
    CGFloat cartesianRadian = CompassToCartesian(radian);
    CGVector offset = CGVectorMake(self.radius * cos(cartesianRadian), self.radius * sin(cartesianRadian));
    return CGPointMake(self.centerPoint.x + offset.dx, self.centerPoint.y + offset.dy);
}

- (CGFloat)radianFromPoint:(CGPoint)fromPoint toReferencePoint:(CGPoint)toPoint {
    CGPoint v = CGPointMake(fromPoint.x - toPoint.x,fromPoint.y - toPoint.y);
    double cartesianRadian = atan2(v.y, v.x);
    double compassRadian = CartesianToCompass(cartesianRadian);
    if (compassRadian < 0) {
        compassRadian += (2 * M_PI);
    }
    
    return compassRadian;
}

#pragma mark -
#pragma mark Tracking Touches

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    [super beginTrackingWithTouch:touch withEvent:event];
//    [self sendActionsForControlEvents:UIControlEventTouchDragEnter];
//    return YES;
//}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    self.radianFromNorth = [self radianFromPoint:lastPoint toReferencePoint:self.centerPoint];
    
    BOOL continueTracking = YES;
    if (self.radianFromNorth > self.endradianFromNorth) {
        self.radianFromNorth = self.endradianFromNorth;
        [self sendActionsForControlEvents:UIControlEventTouchDragExit];
        continueTracking = NO;
    } else if (self.radianFromNorth < self.startradianFromNorth) {
        self.radianFromNorth = self.startradianFromNorth;
        [self sendActionsForControlEvents:UIControlEventTouchDragExit];
        continueTracking = NO;
    }
    
    [self moveHandle];
    
    self.currentValue = RADIAN_TO_DEGREE(self.radianFromNorth);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return continueTracking;
}

//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//    [super endTrackingWithTouch:touch withEvent:event];
//    [self sendActionsForControlEvents:UIControlEventTouchDragExit];
//}
//
//- (void)cancelTrackingWithEvent:(UIEvent *)event {
//    [super cancelTrackingWithEvent:event];
//    [self sendActionsForControlEvents:UIControlEventTouchCancel];
//}

#pragma mark -

-(void)moveHandle {
    CGPoint handleCenter = [self pointOnCircleAtRadian:self.radianFromNorth];
    
    //禁用由于改变CALyer的position产生的隐式动画，避免Handle的移动滞后于手势动作
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _outerCircleLayer.position = handleCenter;
    [CATransaction commit];
    
    [self.layer setNeedsDisplay];
}

@end
