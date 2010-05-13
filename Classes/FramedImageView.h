//
//  FramedImageView.h
//  HW6
//
//  Created by 23 on 5/2/10.
//  portions Copyright 2010 RogueSheep. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FramedImageView : UIView
{
	UIImage*			image_;
	// This is the image we draw a frame around
	
	CGFloat				width_;
	// This is the stroke width of our frame around the image
	CGFloat				radius_;
	// This is the radius of our round corners
}

@property (nonatomic, retain)		UIImage*		image;
@property (nonatomic)				CGFloat			width;
@property (nonatomic)				CGFloat			radius;

@end
