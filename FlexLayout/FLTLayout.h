//
//  FLTLayout.h
//  FlexLayout
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FlexLayout/FLTNode.h>

@interface FLTLayout : NSObject

@property (assign, nonatomic, readonly) CGRect frame;
@property (strong, nonatomic, readonly) FLTNode *node;
@property (copy, nonatomic, readonly) NSArray *children;

- (instancetype)initWithNode:(FLTNode *)node children:(NSArray *)children;

- (void)layoutForSize:(CGSize)size;

- (void)layoutViews;
- (void)applyToView:(FLTNodeView *)view;

@end
