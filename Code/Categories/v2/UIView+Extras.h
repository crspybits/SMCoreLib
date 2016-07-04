//
//  UIView+Extras.h
//  Petunia
//
//  Created by Christopher Prince on 9/18/13.
//  Copyright (c) 2013 Spastic Muffin, LLC. All rights reserved.
//

// V2

#import <UIKit/UIKit.h>

typedef void (^AnimationStep)();
typedef void (^AnimationDone)();

@interface UIView (Extras)

// animations must be an array of Blocks of type AnimationStep.
+ (void) performAnimationSequence: (NSArray *) animations andThenCompletion: (AnimationDone) completion;

// The need for this method is a little convoluted. It doesn't seem possible to call animateWithDuration within a loop *even if* the duration is 0. That is, there appears to be some latency (asynchrony) between the animations block and the completion block if duration is 0. So, this special version has no latency/asynchrony between the animations block and the completion block if duration is 0.
+ (void)animateWithDurationSync0:(NSTimeInterval)duration animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

// Put your animations, e.g., frame changes, in a block.
+ (void) animateBlock: (void (^)(void)) blockToAnimate;

// WRT frame.
- (void) centerVerticallyInSuperview;
- (void) centerHorizontallyInSuperview;
- (void) centerInSuperview;

// WRT to bounds. Use these if the view is transformed.
- (void) centerVerticallyInSuperviewBounds;
- (void) centerHorizontallyInSuperviewBounds;
- (void) centerInSuperviewBounds;

// make sure all of the view is contained in the frame of the receiver, and if it is not, adjust it so that it is. Assumes view is a subview of the receiver. Also assumes that the height and width of the view are smaller than the height and width of the receiver.
// Constrain the receivers frame to the view's frame.
- (void) constrainToFrame: (UIView *) view;

@property (nonatomic) CGFloat frameX;
@property (nonatomic) CGFloat frameY;
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;
@property (nonatomic) CGPoint frameOrigin;
@property (nonatomic) CGSize frameSize;

@property (nonatomic) CGFloat boundsX;
@property (nonatomic) CGFloat boundsY;
@property (nonatomic) CGFloat boundsWidth;
@property (nonatomic) CGFloat boundsHeight;

// For debugging
@property (nonatomic) BOOL debugBlackBorder;

@end
