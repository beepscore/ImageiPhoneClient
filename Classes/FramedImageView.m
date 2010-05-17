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
@synthesize borderWidth	= borderWidth_;
@synthesize cornerRadius	= cornerRadius_;

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
	borderWidth_	= 5.0f;
	cornerRadius_	= 5.0f;
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

- (void) setBorderWidth:(CGFloat)newWidth
{
	if ( newWidth != borderWidth_ )
	{
		[self setNeedsDisplay];
		borderWidth_ = newWidth;
	}
}

- (void) setCornerRadius:(CGFloat)newRadius
{
	if ( newRadius != cornerRadius_ )
	{
		[self setNeedsDisplay];
		cornerRadius_ = newRadius;
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
// Ref Gelphman Ch 6 pg 114-115, 132-133
CGMutablePathRef roundedRectPathRef(CGRect rect, CGFloat ovalWidth, CGFloat ovalHeight) {
    
    CGMutablePathRef tempPath = CGPathCreateMutable(); 
    
    CGRect offsetRect = rect;
    NSUInteger kDrawingViewWidth = 320;
    NSUInteger kDrawingViewHeight = 320;
    CGFloat fw, fh;
    
    offsetRect.origin.x = (kDrawingViewWidth - rect.size.width)/2;
    offsetRect.origin.y = (kDrawingViewHeight - rect.size.height)/2;
    
    // if either ovalWidth or ovalHeight is 0, don't round corners
    if ((0 == ovalWidth) || (0 == ovalHeight)) {
        
        CGPathAddRect(tempPath, NULL, offsetRect);
    } else {
        
        CGAffineTransform transformOrigin = 
        CGAffineTransformTranslate(CGAffineTransformIdentity, offsetRect.origin.x, offsetRect.origin.y);
        
        // Non-uniform scale coordinate system by the oval width and height.
        // In scaled coordinates, each rounded corner is a circular arc of radius = 0.5
        CGAffineTransform transformScale = CGAffineTransformScale(transformOrigin, ovalWidth, ovalHeight);
        
        // Rectangle width in scaled x coordinate
        fw = CGRectGetWidth(rect) / ovalWidth;
        // Rectangle height in scaled y coordinate
        fh = CGRectGetHeight(rect) / ovalHeight;        
        
        CGFloat scaledRadius = 0.5;
        
        // Start at minimum x,y corner (on iPhone, left top)
        CGPoint arc1Center = CGPointMake(scaledRadius, scaledRadius);        
        // on iPhone, right top
        CGPoint arc2Start  = CGPointMake((fw - scaledRadius), 0);
        CGPoint arc2Center = CGPointMake((fw - scaledRadius), scaledRadius);
        // on iPhone, right bottom
        CGPoint arc3Start  = CGPointMake(fw, (fh - scaledRadius));
        CGPoint arc3Center = CGPointMake((fw - scaledRadius), (fh - scaledRadius));
        // on iPhone, left bottom        
        CGPoint arc4Start  = CGPointMake(scaledRadius, fh);
        CGPoint arc4Center = CGPointMake(scaledRadius, (fh - scaledRadius));
        
        CGPathAddArc(tempPath, &transformScale, arc1Center.x, arc1Center.y, scaledRadius, -M_PI, -M_PI/2, NO);
        
        CGPathAddLineToPoint(tempPath, &transformScale, arc2Start.x, arc2Start.y);        
        CGPathAddArc(tempPath, &transformScale, arc2Center.x, arc2Center.y, scaledRadius, -M_PI/2, 0, NO);
        
        CGPathAddLineToPoint(tempPath, &transformScale, arc3Start.x, arc3Start.y);        
        CGPathAddArc(tempPath, &transformScale, arc3Center.x, arc3Center.y, scaledRadius, 0, M_PI/2, NO);
        
        CGPathAddLineToPoint(tempPath, &transformScale, arc4Start.x, arc4Start.y);        
        CGPathAddArc(tempPath, &transformScale, arc4Center.x, arc4Center.y, scaledRadius, M_PI/2, M_PI, NO);
        
        // Closing the path adds the last segment from arc4 end to arc1 start.
        CGPathCloseSubpath(tempPath);
    }
    return tempPath;
}


void drawDropShadow(CGContextRef graphicsContext, CGRect rect, CGPathRef myPath, CGFloat aBorderWidth) {
    
    CGContextSaveGState(graphicsContext);
    CGFloat xScale = (rect.size.width + aBorderWidth)/rect.size.width;
    CGFloat yScale = (rect.size.height + aBorderWidth)/rect.size.height;
    
    CGContextTranslateCTM(graphicsContext, rect.size.width/2, rect.size.height/2);
    CGContextScaleCTM(graphicsContext, xScale, yScale);
    CGContextTranslateCTM(graphicsContext, -rect.size.width/2, -rect.size.height/2);
    // offset shadow
    CGContextTranslateCTM(graphicsContext, 0.01 * rect.size.width, 0.02 * rect.size.height);
    
    CGContextAddPath(graphicsContext, myPath);
    
    
    CGContextSetRGBFillColor(graphicsContext, 0.0, 0.0, 0.0, 0.4);
    CGContextFillPath(graphicsContext);
    
    // increase DropShadow size based on border width  ref Gelphman p 138
    CGContextReplacePathWithStrokedPath (graphicsContext);
    CGContextFillPath(graphicsContext);
    
    CGContextRestoreGState(graphicsContext);
}


void drawClippedImage(CGContextRef graphicsContext, CGRect rect, CGImageRef anImage, CGPathRef aPath) {
    
    CGContextSaveGState(graphicsContext);
    
    CGContextAddPath(graphicsContext, aPath);
    CGContextClip(graphicsContext);
    
    // Here we get a CGImageRef from a Cocoa UIImage.
    // Alternatively, we could have gotten a CGImageRef from C.
    // http://developer.apple.com/iphone/library/documentation/Cocoa/Conceptual/LoadingResources/ImageSoundResources/ImageSoundResources.html
    // Ref Gelphman Ch 8 p 187, Ch 9 p 206-207   
    CGContextDrawImage(graphicsContext, rect, anImage);
    
    // turn off clipping
    CGContextRestoreGState(graphicsContext);
}


void drawBorder(CGContextRef graphicsContext, CGPathRef myPath, CGFloat aBorderWidth) {
    
    CGContextSaveGState(graphicsContext);
    
    CGContextBeginPath(graphicsContext);
    CGContextAddPath(graphicsContext, myPath);
    
    CGContextSetLineWidth(graphicsContext, aBorderWidth);
    CGContextSetRGBStrokeColor(graphicsContext, 1.0, 1.0, 1.0, 1.0);
    
    CGContextDrawPath(graphicsContext, kCGPathStroke);
    
    CGContextRestoreGState(graphicsContext);
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


- (void)drawRect:(CGRect)rect
{
	// HW_TODO :
    
	// ADD YOUR DRAWING CODE FROM THE LAST ASSIGNMENT WITH 1 CHANGE :
	
	// IF WE DON'T HAVE AN IMAGE YET, DRAW THE PLACEHOLDER
    // DO THIS BY CHOOSING TO DRAW THE PLACEHOLDER OR THE IMAGE
    
    
    // get graphics context from Cocoa for use by Quartz CoreGraphics.    
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    // CGRectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
    CGRect clipRect = CGRectMake(20.0, 20.0, 280.0, 280.0);
    CGFloat ovalWidth = [self cornerRadius];
    CGFloat ovalHeight = ovalWidth;
    
    // Create a new CGMutablePathRef each time.  Chris thinks this is low overhead.
    // Alternatively could make myPath a class ivar and change it's value.    
    CGMutablePathRef myPath = roundedRectPathRef(clipRect, ovalWidth, ovalHeight);
    
	
	if (nil == self.image)
	{
		[self drawPlaceholder];
	} else
    {
        
        drawDropShadow(graphicsContext, [self bounds], myPath, self.borderWidth);
        
        //    drawClippedImage(graphicsContext, [self bounds], [self.myImage CGImage], myPath);
        drawClippedImage(graphicsContext, [self bounds], [self.image CGImage], myPath);
        
        drawBorder(graphicsContext, myPath, self.borderWidth);
        
        
        
        
//		[image_ drawInRect:imageBounds];
    }
	
	// FOLLOW UP WITH ANY OTHER AFTER IMAGE DRAWING AS BEFORE
    CGPathRelease(myPath);	
}


@end
