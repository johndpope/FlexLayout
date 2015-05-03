//
//  FlexLayoutTests.m
//  FlexLayoutTests
//
//  Created by Michael Schneider
//  Copyright (c) 2015 mischneider. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "FLTLayout.h"

@interface FlexLayoutTests : XCTestCase

@end

@implementation FlexLayoutTests

- (void)testDescription
{
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.direction = FLTNodeDirectionColumn;
        n.size = CGSizeMake(300, 300);
        n.padding = FLTEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.margin = FLTEdgeInsetsMake(0, 0, 0, 0);
                n.size = CGSizeMake(0, 100);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.margin = FLTEdgeInsetsMake(10, 0, 0, 0);
                n.size = CGSizeMake(FLTNodeUndefinedValue, 100.0);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.flex = 10;
                n.margin = FLTEdgeInsetsMake(10, 10, 10, 10);
                n.size = CGSizeMake(0, 180);
            }],
        ];
    }];
    FLTLayout *layout = [parent buildLayout];
    XCTAssert(layout.description.length > 0, "Has a description.");
}

- (void)testSizeParentBasedOnChildren
{
    FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.children = @[
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.size = CGSizeMake(100, 200);
            }],
            [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
                n.size = CGSizeMake(300, 150);
            }]
        ];
    }];
    FLTLayout *layout = [parent buildLayout];
    XCTAssertTrue(CGSizeEqualToSize(layout.frame.size, CGSizeMake(300, 350)));
}

- (void)testMeasureIsUsed
{
    CGSize measuredSize = CGSizeMake(123, 456);
    FLTNode *node = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.measure = ^CGSize(CGFloat width) {
            return measuredSize;
        };
    }];
    FLTLayout *layout = [node buildLayout];
    XCTAssertTrue(CGSizeEqualToSize(layout.frame.size, measuredSize));
}

- (void)testMaxWidthIsUsed
{
    CGFloat maxWidth = 345;
    __block CGFloat maxWidthGiven = 0;
    FLTNode *node = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
        n.measure = ^CGSize(CGFloat width) {
            maxWidthGiven = width;
            return CGSizeMake(1, 1);
        };
    }];
    __unused FLTLayout *layout = [node buildLayoutWithMaxWidth:maxWidth];
    XCTAssertEqual(maxWidthGiven, maxWidth);
}

@end
