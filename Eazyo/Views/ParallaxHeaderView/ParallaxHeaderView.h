//
//  ParallaxHeaderView.h
//  ParallaxTableViewHeader
//
//  Created by Vinodh  on 26/10/14.
//  Copyright (c) 2014 Daston~Rhadnojnainva. All rights reserved.

//

#import <UIKit/UIKit.h>

@interface ParallaxHeaderView : UIView
@property (nonatomic) UIImage *headerImage;
@property (nonatomic) int padding;
@property (nonatomic) UIImageView *imageView;

+ (id)parallaxHeaderViewWithImage:(UIImage *)image forSize:(CGSize)headerSize withPadding:(int)pad;
+ (id)parallaxHeaderViewWithSubView:(UIView *)subView;
- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;

@end
