//
//  FLTNode.h
//  FlexLayout
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <Foundation/Foundation.h>

#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
typedef UIView FLTNodeView;
typedef UIEdgeInsets FLTEdgeInsets;
#else
#import <AppKit/AppKit.h>
typedef NSView FLTNodeView;
typedef NSEdgeInsets FLTEdgeInsets;
#endif

@class FLTLayout;

NS_ASSUME_NONNULL_BEGIN

/// Wrapper around UIEdgeInsetsMake and NSEdgeInsetsMake
NS_INLINE FLTEdgeInsets FLTEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
    return UIEdgeInsetsMake(top, left, bottom, right);
#else
    return NSEdgeInsetsMake(top, left, bottom, right);
#endif
}

NS_INLINE FLTEdgeInsets FLTEdgeInsetsMakeUniform(CGFloat uniform) {
    return FLTEdgeInsetsMake(uniform, uniform, uniform, uniform);
}

FOUNDATION_EXPORT const FLTEdgeInsets NodeEdgeInsetsZero;
FOUNDATION_EXPORT const CGFloat FLTNodeUndefinedValue;


typedef enum : NSUInteger {
    FLTNodeDirectionColumn = 0,
    FLTNodeDirectionRow
} FLTNodeDirection;

typedef enum : NSUInteger {
    FLTNodeJustificationFlexStart = 0,
    FLTNodeJustificationCenter,
    FLTNodeJustificationFlexEnd,
    FLTNodeJustificationSpaceBetween,
    FLTNodeJustificationSpaceAround
} FLTNodeJustification;

typedef enum : NSUInteger {
    FLTNodeChildAlignmentAuto = 0,
    FLTNodeChildAlignmentFlexStart,
    FLTNodeChildAlignmentCenter,
    FLTNodeChildAlignmentFlexEnd,
    FLTNodeChildAlignmentStretch
} FLTNodeChildAlignment;

typedef enum : NSUInteger {
    FLTNodeSelfAlignmentAuto = 0,
    FLTNodeSelfAlignmentFlexStart,
    FLTNodeSelfAlignmentCenter,
    FLTNodeSelfAlignmentFlexEnd,
    FLTNodeSelfAlignmentStretch
} FLTNodeSelfAlignment;

@interface FLTNodeBuilder : NSObject

@property (strong, nonatomic, nullable) FLTNodeView *view;
@property (assign, nonatomic) CGSize size;
@property (copy, nonatomic, nullable) NSArray *children;
@property (assign, nonatomic) FLTNodeDirection direction;
@property (assign, nonatomic) FLTEdgeInsets margin;
@property (assign, nonatomic) FLTEdgeInsets padding;
@property (assign, nonatomic) BOOL wrap;
@property (assign, nonatomic) FLTNodeJustification justification;
@property (assign, nonatomic) FLTNodeSelfAlignment selfAlignment;
@property (assign, nonatomic) FLTNodeChildAlignment childAlignment;
@property (assign, nonatomic) CGFloat flex;
@property (copy, nonatomic, nullable) CGSize (^measure)(CGFloat width);

@end

@interface FLTNode : NSObject

@property (strong, nonatomic, readonly, nullable) FLTNodeView *view;
@property (assign, nonatomic, readonly) CGSize size;
@property (copy, nonatomic, readonly, nullable) NSArray *children;
@property (assign, nonatomic, readonly) FLTNodeDirection direction;
@property (assign, nonatomic, readonly) FLTEdgeInsets margin;
@property (assign, nonatomic, readonly) FLTEdgeInsets padding;
@property (assign, nonatomic, readonly) BOOL wrap;
@property (assign, nonatomic, readonly) FLTNodeJustification justification;
@property (assign, nonatomic, readonly) FLTNodeSelfAlignment selfAlignment;
@property (assign, nonatomic, readonly) FLTNodeChildAlignment childAlignment;
@property (assign, nonatomic, readonly) CGFloat flex;
@property (copy, nonatomic, readonly, nullable) CGSize (^measure)(CGFloat width);

+ (instancetype)nodeWithBlock:(void (^)(FLTNodeBuilder *nodeBuilder))block;
- (instancetype)init NS_UNAVAILABLE;

- (FLTLayout *)buildLayout;
- (FLTLayout *)buildLayoutWithMaxWidth:(CGFloat)maxWidth;

@end

/// Helper function to create FTLNode objects
FLTNode *FLTNodeMake(void(^block)(FLTNodeBuilder *nodeBuilder));

NS_ASSUME_NONNULL_END
