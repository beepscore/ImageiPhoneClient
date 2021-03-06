//
//  FramedImageView.m
//  HW6
//
//  Created by 23 on 5/2/10.
//  portions Copyright 2010 RogueSheep. All rights reserved.
//  portions Copyright Beepscore LLC 2010. All rights reserved.
//

#import "FramedImageView.h"

// declare anonymous category for "private" methods, avoid showing in .h file
// Note in Objective C no method is private, it can be called from elsewhere.
// Ref http://stackoverflow.com/questions/1052233/iphone-obj-c-anonymous-category-or-private-category
@interface FramedImageView ()

- (void) drawPlaceholderInContext:(CGContextRef) aGraphicsContext
                             rect:(CGRect) aRect
                    clippedToPath:(CGPathRef)aPath;
- (void) initialize;

@end


@implementation FramedImageView

@synthesize	image	= image_;
@synthesize borderWidth	= borderWidth_;
@synthesize cornerRadius	= cornerRadius_;

// instantiating programmatically calls initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self initialize];  	
    }
    return self;
}

// instantiating from a nib calls initWithCoder:
// Alternatively could call [self initialize] in awakeFromNib.
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
    
    CGFloat fw, fh;
    
    // if either ovalWidth or ovalHeight is 0, don't round corners
    if ((0 == ovalWidth) || (0 == ovalHeight)) {
        
        CGPathAddRect(tempPath, NULL, rect);
    } else {
        
        CGAffineTransform transformOrigin = 
        //CGAffineTransformTranslate(CGAffineTransformIdentity, offsetRect.origin.x, offsetRect.origin.y);
        CGAffineTransformTranslate(CGAffineTransformIdentity, rect.origin.x, rect.origin.y);
        
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


// ref Lecture_7.pdf
// ref http://developer.apple.com/iphone/library/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html
- (void) drawGradientInContext:(CGContextRef) graphicsContext
                          rect:(CGRect) rect
                          path:(CGPathRef) myPath
{
    CGContextSaveGState(graphicsContext);
    CGContextAddPath(graphicsContext, myPath);
    CGContextClip(graphicsContext);
    
    CGGradientRef myGradient;    
    CGColorSpaceRef myColorspace;    
    size_t num_locations = 2;    
    CGFloat locations[2] = { 0.0, 1.0 };    
    CGFloat components[8] = { 0.4, 0.4, 0.8, 1.0,  // Start color
        0.1, 0.1, 0.2, 1.0 }; // End color
    
    // ref http://stackoverflow.com/questions/560254/kcgcolorspacegenericrgb-is-deprecated-on-iphone
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
        
    CGPoint start = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height * 0.25);
    CGPoint end = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height * 0.75);
    CGGradientDrawingOptions options = 0;
    options |= kCGGradientDrawsBeforeStartLocation;
    options |= kCGGradientDrawsAfterEndLocation;
    
    CGContextDrawLinearGradient(graphicsContext, myGradient, start, end, options);
    
    CGColorSpaceRelease(myColorspace);
    CGGradientRelease(myGradient);
    
    CGContextRestoreGState(graphicsContext);
}


// draw border with shadow
- (void) drawBorderOfWidth:(CGFloat) aBorderWidth
                 InContext:(CGContextRef) aGraphicsContext
             clippedToPath:(CGPathRef)aPath
{
    CGContextSaveGState(aGraphicsContext);
    
    CGContextBeginPath(aGraphicsContext);
    CGContextAddPath(aGraphicsContext, aPath);
    
    CGContextSetLineWidth(aGraphicsContext, aBorderWidth);
    CGContextSetRGBStrokeColor(aGraphicsContext, 1.0, 1.0, 1.0, 1.0);
    
    // turn shadow on
    CGSize offset = CGSizeMake(3.0f, -4.0f);
    CGFloat blur = 6.0f;
    CGContextSetShadowWithColor(aGraphicsContext, offset, blur, [[UIColor blackColor] CGColor]);
    
    // draw path with shadow
    CGContextDrawPath(aGraphicsContext, kCGPathStroke);
    
    // restore state including turn shadow off
    CGContextRestoreGState(aGraphicsContext);
}


- (void) drawPlaceholderInContext:(CGContextRef) aGraphicsContext
                             rect:(CGRect) aRect
                    clippedToPath:(CGPathRef)aPath
{
	// if we don't have an image draw a simple little placeholder
    
    CGContextSaveGState(aGraphicsContext);
    
    // draw border with shadow
    [self drawBorderOfWidth:self.borderWidth
                  InContext:aGraphicsContext 
              clippedToPath:aPath];    
    
	// draw gradient clipped to path.
    // This draws over part of border and shadow    
    [self drawGradientInContext:aGraphicsContext
                           rect:self.bounds
                           path:aPath];
    
    
    // draw text informing the user why there is no image
    CGContextSelectFont(aGraphicsContext, "Helvetica", 36.0, kCGEncodingMacRoman);
    
    NSString*	placeholderString = @"Waiting for image from Service";
    
    CGFloat		textFontSize = 28.0f; 
    UIFont*		textFont = [UIFont fontWithName:@"Helvetica-Bold" size:textFontSize];
    
    CGFloat		textHInset		= 40.0f;
    CGFloat		textVInset		= 55.0f;
    
    CGRect		textRect = self.bounds;
    textRect = CGRectInset(textRect, textHInset * 2.0f, textVInset * 2.0f);
    
    
	// turn on shadow for text
    CGSize offset = CGSizeMake(3.0f, -4.0f);
    CGFloat blur = 4.0f;
    CGContextSetShadowWithColor(aGraphicsContext, offset, blur, [[UIColor blackColor] CGColor]);
    
    CGContextSetRGBFillColor(aGraphicsContext, 1.0, 1.0, 1.0, 1.0);    
    [placeholderString drawInRect:textRect
                         withFont:textFont
                    lineBreakMode:UILineBreakModeWordWrap
                        alignment:UITextAlignmentCenter];
    
    // restore context including turn shadow off
    CGContextRestoreGState(aGraphicsContext);    
}


- (void) drawImage:(UIImage*) anImage
           context:(CGContextRef) aGraphicsContext
              rect:(CGRect) aRect
     clippedToPath:(CGPathRef) aPath
{    
    CGContextSaveGState(aGraphicsContext);    
    
    [self drawBorderOfWidth:self.borderWidth
                  InContext:aGraphicsContext 
              clippedToPath:aPath];    
    
    CGContextAddPath(aGraphicsContext, aPath);

    // draw image
    // This draws over part of border and shadow, keeps most of image visible   
    CGContextClip(aGraphicsContext);    
    [anImage drawInRect:aRect];

    // restore context including turn clipping off
    CGContextRestoreGState(aGraphicsContext);
}


- (void)drawRect:(CGRect)rect
{    
    // get graphics context from Cocoa for use by Quartz CoreGraphics.    
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    
    CGFloat dx = 20.0;
    CGFloat dy = 20.0;
    
    CGRect clipRect = CGRectInset(self.bounds, dx, dy);    
    CGFloat ovalWidth = [self cornerRadius];
    CGFloat ovalHeight = ovalWidth;
    
	// if we don't have an image, draw placeholder
	if (nil == self.image)
	{
        // Create a new CGMutablePathRef each time.  Chris thinks this is low overhead.
        // Alternatively could make myPath a class ivar and change it's value.    
        CGMutablePathRef myPath = roundedRectPathRef(clipRect, ovalWidth, ovalHeight);
        
        [self drawPlaceholderInContext:graphicsContext 
                                  rect:clipRect
                         clippedToPath:myPath];
        
        CGPathRelease(myPath);
        
	} else    
    {
        // draw image
        
        // resize clipRect to preserve image aspect ratio
        // Alternatively, could non-uniform scale CTM.
        // However then would have to avoid scaling corners and stroke widths.

        CGFloat imageAspectRatio = (self.image.size.width / self.image.size.height);
        NSLog(@"imageAspectRatio = %f", imageAspectRatio);
        CGFloat clipRectAspectRatio = (clipRect.size.width / clipRect.size.height);
        NSLog(@"clipRectAspectRatio = %f", clipRectAspectRatio);
        
        if (imageAspectRatio > clipRectAspectRatio) {
            // image is "more" landscape than screen.  shrink screen rect height
            CGFloat oldHeight = clipRect.size.height;
            clipRect.size.height =  (clipRect.size.width / imageAspectRatio);
            //clipRect.origin.y = ((oldHeight - clipRect.size.height) / (imageAspectRatio/clipRectAspectRatio));
            clipRect.origin.y = (clipRectAspectRatio * (oldHeight - clipRect.size.height));
        }
        else {
            if (imageAspectRatio < clipRectAspectRatio) {
                // image is "more" portrait than screen.  shrink screen rect width
                CGFloat oldWidth = clipRect.size.width;
                clipRect.size.width = (imageAspectRatio * clipRect.size.height);
                clipRect.origin.x = ((oldWidth - clipRect.size.width)/clipRectAspectRatio);
            }
        }
        
        CGMutablePathRef myPath = roundedRectPathRef(clipRect, ovalWidth, ovalHeight);        
        
        [self drawImage:self.image
                context:graphicsContext
                   rect:clipRect
          clippedToPath:myPath];
        
        CGPathRelease(myPath);
    }    
}

@end
