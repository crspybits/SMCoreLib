//
//  UIView+Extras.h
//  Petunia
//
//  Created by Christopher Prince on 9/18/13.
//  Copyright (c) 2013 Spastic Muffin, LLC. All rights reserved.
//

// V1

#import <UIKit/UIKit.h>

typedef void (^AnimationStep)();
typedef void (^AnimationDone)();

@interface UIView (Extras)

// Animations must be an array of Blocks of type AnimationStep.
// 1/13/15. I don't think this works with all cases of iOS animations. See note [1] in CoreDataTableViewController.m.
// See also http://stackoverflow.com/questions/7196197/catransaction-synchronize-called-within-transaction/10309729#10309729
+ (void) performAnimationSequence: (NSArray *) animations andThenCompletion: (AnimationDone) completion;

// The need for this method is a little convoluted. It doesn't seem possible to call animateWithDuration within a loop *even if* the duration is 0. That is, there appears to be some latency (asynchrony) between the animations block and the completion block if duration is 0. So, this special version has no latency/asynchrony between the animations block and the completion block if duration is nil.
+ (void)animateWithDurationSync0:(NSNumber *)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

// Put your animations, e.g., frame changes, in a block.
+ (void) animateBlock: (void (^)(void)) blockToAnimate;

- (void) setFrameSize: (CGSize) size;
- (void) setFrameOrigin: (CGPoint) origin;
- (void) setFrameX: (CGFloat) x;
- (void) setFrameY: (CGFloat) y;
- (void) setFrameMaxX: (CGFloat) frameMaxX;
- (void) setFrameMaxY: (CGFloat) frameMaxY;
- (void) setFrameHeight: (CGFloat) height;
- (void) setFrameWidth: (CGFloat) width;

- (void) setCenterX: (CGFloat) x;
- (void) setCenterY: (CGFloat) y;

- (void) setBoundsOrigin: (CGPoint) origin;
- (void) setBoundsSize: (CGSize) size;
- (void) setBoundsHeight: (CGFloat) height;
- (void) setBoundsWidth: (CGFloat) width;
- (void) setBoundsMaxX: (CGFloat) boundsMaxX;
- (void) setBoundsMaxY: (CGFloat) boundsMaxY;

// WRT frame.
- (void) centerVerticallyInSuperview;
- (void) centerHorizontallyInSuperview;
- (void) centerInSuperview;

// WRT to bounds. Use these if the view is transformed.
- (void) centerVerticallyInSuperviewBounds;
- (void) centerHorizontallyInSuperviewBounds;
- (void) centerInSuperviewBounds;

// Assumes views have already been added to superview. Makes white space between the views equal.
+ (void) distributeViewsHorizontally: (NSArray *) views;

- (void) removeAllSubviews;

@property (nonatomic, readonly) CGFloat frameX;
@property (nonatomic, readonly) CGFloat frameY;
@property (nonatomic, readonly) CGFloat frameMaxX;
@property (nonatomic, readonly) CGFloat frameMaxY;
@property (nonatomic, readonly) CGFloat frameWidth;
@property (nonatomic, readonly) CGFloat frameHeight;
@property (nonatomic, readonly) CGPoint frameOrigin;
@property (nonatomic, readonly) CGSize frameSize;

@property (nonatomic, readonly) CGFloat boundsX;
@property (nonatomic, readonly) CGFloat boundsY;
@property (nonatomic, readonly) CGFloat boundsMaxX;
@property (nonatomic, readonly) CGFloat boundsMaxY;
@property (nonatomic, readonly) CGFloat boundsWidth;
@property (nonatomic, readonly) CGFloat boundsHeight;
@property (nonatomic, readonly) CGPoint boundsOrigin;
@property (nonatomic, readonly) CGSize boundsSize;

@property (nonatomic, readonly) CGFloat centerX;
@property (nonatomic, readonly) CGFloat centerY;

// For debugging
@property (nonatomic) BOOL debugBlackBorder;
@property (nonatomic) UIColor *debugBorderColor;

- (void) setDebugBlackBorder: (BOOL) blackBorder;
- (void) setDebugBorderColor:(UIColor *) color;

@end
