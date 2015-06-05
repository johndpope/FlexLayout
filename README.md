# FlexLayout

Small Objective-C wrapper around Facebook's [implementation](https://github.com/facebook/css-layout) of CSS's flexbox.

Inspired by [SwiftBox](https://github.com/joshaber/SwiftBox).

## Usage

This is a small iOS example for layout a UITableViewCell with a column layout. The cell has a dynamic height that depends on the height of the title and the description text. Title and description will automatically break to a new line if they are getting too long for the cell width. The image that is between the title and the description has a static height. All three views will be stretched in width.

Create a layout:
```objective-c
__weak SomeCellClass *weakCell = someCell;

FLTNode *parent = [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
    n.view = weakCell.contentView;
    n.direction = FLTNodeDirectionColumn;
    n.padding = FLTEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    n.children = @[
        [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
            n.view = weakCell.titleLabel,
            n.measure = ^CGSize(CGFloat width) {
                if (isnan(width)) { return CGSizeZero; }
                return [weakCell.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
            };
        }],
        [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
            n.view = weakCell.posterImageView,
            n.margin = FLTEdgeInsetsMake(10, 0, 0, 0);
            n.size = CGSizeMake(FLTNodeUndefinedValue, 300.0);
        }],
        [FLTNode nodeWithBlock:^(FLTNodeBuilder *n) {
            n.view = weakCell.descriptionLabel,
            n.margin = FLTEdgeInsetsMake(10, 10, 10, 10);
            n.measure = ^CGSize(CGFloat width) {
                if (isnan(width)) { return CGSizeZero; }
                return [weakCell.descriptionLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
            };
        }],

    ];
}];

weakCell.layout = [parent buildLayout];
```

Layout all the views in e.g. layoutSubviews:
```objective-c
[self.layout layoutForSize:self.contentView.bounds.size];
[self.layout layoutViews];
```

The dynamic height of the cell can be directly retrieved from the layout:
```objective-c
[self.layout layoutForSize:CGSizeMake(self.contentView.bounds.size.width, FLTNodeUndefinedValue)];
CGFloat height = CGRectGetHeight(self.layout.frame);
```


You don't have to necessary link your views to a layout. You can just create a layout and get frame information for each node this way:
```objective-c
FLTNode *parent = FLTNodeMake(^(FLTNodeBuilder *n) {
    n.size = CGSizeMake(300.0, 300.0);
    n.direction = FLTNodeDirectionRow;
    n.childAlignment = FLTNodeChildAlignmentCenter;
    n.children = @[
        FLTNodeMake(^(FLTNodeBuilder *n) {
            n.flex = 75;
            n.margin = FLTEdgeInsetsMake(0.0, 10.0, 0.0, 10.0);
            n.size = CGSizeMake(0, 100.0);
        }),
        FLTNodeMake(^(FLTNodeBuilder *n) {
            n.flex = 15;
            n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
            n.size = CGSizeMake(0, 50.0);
        }),
        FLTNodeMake(^(FLTNodeBuilder *n) {
            n.flex = 10;
            n.margin = FLTEdgeInsetsMake(0.0, 0.0, 0.0, 10.0);
            n.size = CGSizeMake(0, 180.0);
        })
    ];
});
FLTLayout *layout = [parent buildLayout];
NSLog(@"%@", layout);

// {origin={0.000000, 0.000000}, size={300.000000, 300.000000}}
//	{origin={10.000000, 100.000000}, size={195.000000, 100.000000}}
//	{origin={215.000000, 125.000000}, size={39.000000, 50.000000}}
//	{origin={264.000000, 60.000000}, size={26.000000, 180.000000}}
```

Alternatively, you can than take that layout and apply the layout to a view hierarchy (after ensuring Auto Layout is off):
```objective-c
[layout applyToView:someView];
```

## Demo

See [FlexLayoutDemoiOS](FlexLayoutDemoiOS/FlexLayoutDemoiOS) for an iOS demo and [FlexLayoutDemoMac](FlexLayoutDemoMac/FlexLayoutDemoMac) for a Mac demo.

[![Alt text for your video](http://img.youtube.com/vi/QjAXLGgmDiE/0.jpg)](https://youtu.be/QjAXLGgmDiE)


## TODO:

- Better documentation

## Creator

[Michael Schneider](http://mischneider.net)
[@maicki](https://twitter.com/maicki)

## License

FlexLayout is available under the MIT license. See the LICENSE file for more info.