//
//  FramedImageView.m
//  HW6
//
//  Created by 23 on 5/2/10.
//  portions Copyright 2010 RogueSheep. All rights reserved.
//  portions Copyright Beepscore LLC 2010. All rights reserved.
//

#import "FramedImageView.h"

@interface FramedImageView ()

- (void) drawPlaceholder;
- (void) initialize;

@end


@implementation FramedImageView

@synthesize	image	= image_;
@synthesize width	= width_;
@synthesize radius	= radius_;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self initialize];  	
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
  if (( self = [super initWithCoder:aDecoder]))
  {
	  [self initialize];  	
  }
  return self;
}

- (void) initialize
{
	width_	= 5.0f;
	radius_	= 5.0f;
	image_	= nil;
}

- (void)dealloc
{
	[image_ release];
	image_ = nil;
	
    [super dealloc];
}


#pragma mark -
#pragma mark Properties

- (void) setWidth:(CGFloat)newWidth
{
	if ( newWidth != width_ )
	{
		[self setNeedsDisplay];
		width_ = newWidth;
	}
}

- (void) setRadius:(CGFloat)newRadius
{
	if ( newRadius != radius_ )
	{
		[self setNeedsDisplay];
		radius_ = newRadius;
	}
}

- (void) setImage:(UIImage*)newImage
{
	if (newImage != image_)
	{
		[image_ release];
		image_ = [newImage retain];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
	// HW_TODO :

	// ADD YOUR DRAWING CODE FROM THE LAST ASSIGNMENT WITH 1 CHANGE :
	
	// IF WE DON'T HAVE AN IMAGE YET, DRAW THE PLACEHOLDER
    // DO THIS BY CHOOSING TO DRAW THE PLACEHOLDER OR THE IMAGE
	/*
	if (image_ == nil )
	{
		[self drawPlaceholder];
	}
	{
		[image_ drawInRect:imageBounds];
	}
	*/
	
	// FOLLOW UP WITH ANY OTHER AFTER IMAGE DRAWING AS BEFORE
	
}

- (void) drawPlaceholder
{
	// if we don't have an image
	// draw a simple little placeholder
	
	// HW_TODO :

	// THE PLACE HOLDER NEEDS TO DO THE FOLLOWING FOR CREDIT:
	
	// DRAW A GRADIENT OF SOME SORT, CLIPPED TO THE ROUND RECT PATH
	// THAT THE IMAGE WOULD BE CLIPPED TO
	
	// DRAW SOME TEXT INFORMING THE USER WHY THERE IS NO IMAGE
	// THIS TEXT MUST HAVE A SHADOW DRAW BY THE
	// CGCONTEXT SHADOW API
	
	// HERE IS SOME CODE TO DRAW TEXT USING NSSTRING DRAWING FOR THE IPHONE OS:
	/*
	CGContextSelectFont(context, "Helvetica", 36.0, kCGEncodingMacRoman);
	
	NSString*	placeholderString = @"Waiting for image from Service";

	CGFloat		textFontSize = 28.0f; 
	UIFont*		textFont = [UIFont fontWithName:@"Helvetica-Bold" size:textFontSize];
	
	CGFloat		textHInset		= 40.0f;
	CGFloat		textVInset		= 55.0f;
		
	CGRect		textRect = self.bounds;
				textRect = CGRectInset(textRect, textHInset * 2.0f, textVInset * 2.0f);
	
	[placeholderString drawInRect:textRect withFont:textFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	*/
}


@end
