//
//  FramedImageView.h
//  HW6
//
//  Created by 23 on 5/2/10.
//  portions Copyright 2010 RogueSheep. All rights reserved.
//  portions Copyright Beepscore LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FramedImageView : UIView
{
#pragma mark instance variables
	// This is the image we draw a frame around
	UIImage*			image_;
	
	// This is the stroke width of our frame around the image
	CGFloat				borderWidth_;

	// This is the radius of our round corners	
    CGFloat				cornerRadius_;
}

#pragma mark properties
@property (nonatomic, retain)		UIImage*		image;
@property (nonatomic, assign)		CGFloat			borderWidth;
@property (nonatomic, assign)		CGFloat			cornerRadius;

@end
