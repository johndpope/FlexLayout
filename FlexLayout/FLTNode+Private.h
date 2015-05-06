//
//  FLTNode+Private.h
//  FlexLayout
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <FlexLayout/FLTNode.h>
#import <FlexLayout/Layout.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTNode (Private)

@property (assign, nonatomic, readonly) css_node_t *node;
@property (assign, nonatomic, readonly) CGRect frame;

- (void)layout;
- (void)layoutWithMaxWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
