//
//  FLTLayout.h
//  FlexLayout
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FlexLayout/FLTNode.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTLayout : NSObject

@property (assign, nonatomic, readonly) CGRect frame;
@property (strong, nonatomic, readonly) FLTNode *node;
@property (copy, nonatomic, readonly) NSArray *children;

- (instancetype)initWithNode:(FLTNode *)node children:(NSArray *)children NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
 
- (void)layoutForSize:(CGSize)size;

- (void)layoutViews;
- (void)applyToView:(FLTNodeView *)view;

@end

NS_ASSUME_NONNULL_END