//
//  UIView+Extras.m
//  Petunia
//
//  Created by Christopher Prince on 9/18/13.
//  Copyright (c) 2013 Spastic Muffin, LLC. All rights reserved.
//

// V2

#import "UIView+Extras.h"
#import <QuartzCore/QuartzCore.h>
#import "SPASLog.h"
#import "Assert.h"

@implementation UIView (Extras)

- (void) setFrameOrigin: (CGPoint) origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void) setFrameX: (CGFloat) x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void) setFrameY: (CGFloat) y;
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void) setFrameHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void) setFrameWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void) setFrameSize: (CGSize) size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void) setBoundsX: (CGFloat) x {
    CGRect frame = self.bounds;
    frame.origin.x = x;
    self.bounds = frame;
}

- (void) setBoundsY: (CGFloat) y;
{
    CGRect frame = self.bounds;
    frame.origin.y = y;
    self.bounds = frame;
}

- (void) setBoundsHeight:(CGFloat)height
{
    CGRect frame = self.bounds;
    frame.size.height = height;
    self.bounds = frame;
}

- (void) setBoundsWidth:(CGFloat)width
{
    CGRect frame = self.bounds;
    frame.size.width = width;
    self.bounds = frame;
}

- (CGFloat) frameX
{
    return self.frame.origin.x;
}

- (CGFloat) frameY
{
    return self.frame.origin.y;
}

- (CGFloat) frameWidth
{
    return self.frame.size.width;
}

- (CGFloat) frameHeight
{
    return self.frame.size.height;
}

- (CGPoint) frameOrigin
{
    return self.frame.origin;
}

- (CGSize) frameSize
{
    return self.frame.size;
}

- (CGFloat) boundsX
{
    return self.bounds.origin.x;
}

- (CGFloat) boundsY
{
    return self.bounds.origin.y;
}

- (CGFloat) boundsWidth
{
    return self.bounds.size.width;
}

- (CGFloat) boundsHeight
{
    return self.bounds.size.height;
}

- (void) centerVerticallyInSuperview;
{
    if (! self.superview) return;
    
    SPASLog(@"self.superview.height: %f", self.superview.frameHeight);
    CGFloat superCenterY = self.superview.frameHeight/2.0;
    CGPoint selfCenter = self.center;
    selfCenter.y = superCenterY;
    self.center = selfCenter;
}

- (void) centerHorizontallyInSuperview;
{
    if (! self.superview) return;
    
    //SPASLog(@"self.superview.height: %f", self.superview.frameHeight);
    CGFloat superCenterX = self.superview.frameWidth/2.0;
    CGPoint selfCenter = self.center;
    selfCenter.x = superCenterX;
    self.center = selfCenter;
}

- (void) centerInSuperview;
{
    [self centerVerticallyInSuperview];
    [self centerHorizontallyInSuperview];
}

- (void) centerVerticallyInSuperviewBounds;
{
    if (! self.superview) return;
    
    SPASLog(@"self.superview.height: %f", self.superview.boundsHeight);
    CGFloat superCenterY = self.superview.boundsHeight/2.0;
    CGPoint selfCenter = self.center;
    selfCenter.y = superCenterY;
    self.center = selfCenter;
}

- (void) centerHorizontallyInSuperviewBounds;
{
    if (! self.superview) return;
    
    //SPASLog(@"self.superview.height: %f", self.superview.frameHeight);
    CGFloat superCenterX = self.superview.boundsWidth/2.0;
    CGPoint selfCenter = self.center;
    selfCenter.x = superCenterX;
    self.center = selfCenter;
}

- (void) centerInSuperviewBounds;
{
    [self centerVerticallyInSuperviewBounds];
    [self centerHorizontallyInSuperviewBounds];
}

+ (void) performAnimationSequence: (NSArray *) animations andThenCompletion: (AnimationDone) completion {
    [self performAnimation: 0 fromSequence:animations andThenCompletion:completion];
}

+ (void) performAnimation: (NSUInteger) current fromSequence: (NSArray *) animations andThenCompletion: (AnimationDone) completion {
    
    SPASLog(@"UIView+Extras.performAnimation");
    
    // Base case of recursion
    if (current == [animations count]) {
        if (completion) completion();
        return;
    }
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        // This block runs *after* any animations created before the call to
        // [CATransaction commit] below.
        
        // Next step in recursion
        [self performAnimation: current+1 fromSequence:animations andThenCompletion:completion];
    }];
    
    AnimationStep currentAnimation = animations[current];
    currentAnimation();
    
    [CATransaction commit];
}

// It doesn't seem good to use the same name as in UIView: see http://stackoverflow.com/questions/5272451/overriding-methods-using-categories-in-objective-c
+ (void)animateWithDurationSync0:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    SPASLog(@"UIView+Extras.animateWithDurationSync0");
    if (0.0 == duration) {
        animations();
        if (completion) completion(YES);
    } else {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    }
}

+ (void) animateBlock: (void (^)(void)) blockToAnimate;
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        AssertIf(nil == blockToAnimate, @"Cannot have nil block");
        blockToAnimate();
    } completion:^(BOOL finished) {
    }];
}

- (void) setDebugBlackBorder:(BOOL)blackBorder
{
    CALayer *layer = self.layer;
    if (blackBorder) {
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.borderWidth = 1.0;
    } else {
        layer.borderWidth = 0.0;
    }
}

- (BOOL) debugBlackBorder
{
    CALayer *layer = self.layer;
    return (layer.borderWidth == 1.0);
}

- (void) constrainToFrame: (UIView *) view;
{
    if (view.frameX < 0.0) {
        view.frameX = 0.0;
    }
    else if (view.frameX+view.frameWidth > self.frameWidth) {
        view.frameX = self.frameWidth - view.frameWidth;
    }
    
    if (view.frameY < 0.0) {
        view.frameY = 0.0;
    }
    else if (view.frameY+view.frameHeight > self.frameHeight) {
        view.frameY = self.frameHeight - view.frameHeight;
    }
}

@end
