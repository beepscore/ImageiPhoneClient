//
//  ServiceDetailController.m
//  ImageiPhoneClient
//
//	HW7
//
//  portions Copyright 2010 Chris Parrish
//  portions Copyright Beepscore LLC 2010. All rights reserved.

#import "ImageDetailController.h"
#import "FramedImageView.h"

@interface ImageDetailController ()
- (void) connectToService;
- (void) releaseStreams;
- (void) updateDisplayedImageFromData;
- (void) displayProgressAnimated;
- (void) removeProgressAnimated;


@end

@implementation ImageDetailController

@synthesize	imageView = imageView_;
@synthesize service = service_;
@synthesize radiusSlider = radiusSlider_;
@synthesize widthSlider = widthSlider_;
@synthesize progressView = progressView_;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (service_)
		[self connectToService];
	
	currentImageData_		= nil;
	currentImageDataSize_	= 0;
	
	imageView_.image		=	nil;
	
	// sync up the sliders and the view
	imageView_.width		=	widthSlider_.value;
	imageView_.radius		=	radiusSlider_.value;
	
	progressView_.alpha		= 0.0;
	// hide the progress view until we need it
	
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.imageView = nil;
	self.service = nil;
	self.radiusSlider	= nil;
	self.widthSlider	= nil;
	
	[self releaseStreams];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[self releaseStreams];
}

- (void) releaseStreams
{
	[outputStream_ close];
	[outputStream_ release];
	outputStream_ = nil;

	[inputStream_ close];
	[inputStream_ release];
	inputStream_ = nil;
}

- (void)dealloc
{	
	[self releaseStreams];
	
	[imageView_ release];
	imageView_ = nil;

	[service_ release];
	imageView_ = nil;	
	
	[radiusSlider_ release];
	radiusSlider_ = nil;
	
	[widthSlider_ release];
	widthSlider_ = nil;		
	
    [super dealloc];
}

#pragma mark -
#pragma mark Service

- (void) connectToService
{
	// We assume the NSNetService has been resolved at this point
	// NSNetService makes it easy for us to connect, we don't have to do any socket management
		
	[service_ getInputStream:&inputStream_ outputStream:&outputStream_];
	
	if ( inputStream_ != nil )
	{	
		[inputStream_ retain];
		[inputStream_ setDelegate:self];
		[inputStream_ scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[inputStream_ open];	
		
		
		[currentImageData_ release];
		currentImageDataSize_ = 0;		
	}
	
	if ( outputStream_ != nil )
	{
		[outputStream_ open];
		[outputStream_ retain];
	}
	
	if ( outputStream_ == nil || inputStream_ == nil )
	{
		 NSLog(@"Problem connecting to service: could not open input or output stream");
	}	
	
}

- (void) sendMessage:(NSString*)messageText
{
	if ( outputStream_ == nil )
	{
		NSLog(@"Failed to send message, not connected.");
		return;
	}
		
	const uint8_t*	messageBuffer = (const uint8_t*)[messageText UTF8String];
	NSUInteger		length = [messageText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	[outputStream_ write:messageBuffer maxLength:length+1];
	// add one to the length returned, because it does not include the null terminator 
	// this is a synchronous write	
}

#pragma mark NSStream Notification

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)event
{
    switch(event)
	{
        case NSStreamEventHasBytesAvailable:
            if (!currentImageData_)
			{
				// the first data we should be seeing is the size of the image
				
				NSUInteger maxLength = sizeof(NSUInteger);
				uint8_t readBuffer[ maxLength ];
				int amountRead = 0;
				NSInputStream* inputStream = (NSInputStream*)aStream;
				amountRead = [inputStream read:readBuffer maxLength:maxLength];
				
				if (amountRead < maxLength)
				{
					NSLog(@"Read error : execpted %d bytes indicating size of image, only read %d bytes",maxLength, amountRead);
					return;
				}
				
				NSUInteger* dataSize = (NSUInteger*)readBuffer;
				currentImageDataSize_ = ntohl( (*dataSize) );
				// note that we cast the read buffer pointer to bytes to a pointer
				// to an NSUnisgned int. To be safe, we also need to to make
				// sure we fix the byte order from network to host
				
                currentImageData_ = [[NSMutableData alloc] initWithCapacity:409600];
				
				// add the progress indicator view
				[self displayProgressAnimated];
            }
			else
			{
				uint8_t readBuffer[4096];
				int amountRead = 0;
				NSInputStream* is = (NSInputStream *)aStream;
				amountRead = [is read:readBuffer maxLength:4096];
				[currentImageData_ appendBytes:readBuffer length:amountRead];

				// update the progress view
				float progress = (float)[currentImageData_ length] / (float)currentImageDataSize_;
				self.progressView.progress = progress;

				
				if ( [currentImageData_ length] >= currentImageDataSize_ )
				{
					// At this point we have all the data
					// so we can display the image
					[self updateDisplayedImageFromData];
					
					[currentImageData_ release];
					currentImageData_ = nil;
					
					[self removeProgressAnimated];
				}
				
			}
			break;
			
        case NSStreamEventEndEncountered:
			
			// This indicates that the service has closed the communication channel
			// In this case we want to pop our view controller off the stack
            [(NSInputStream *)aStream close];
			[[self navigationController] popViewControllerAnimated:YES];

			break;

        default:
            break;
    }
}

- (void) updateDisplayedImageFromData
{
	// At this point we have all the data
	// so we can display the image
	UIImage* newImage = [[UIImage alloc] initWithData:currentImageData_];
	imageView_.image = newImage;
	[newImage release];
}

#pragma mark -
#pragma mark Progress

- (void) displayProgressAnimated
{
	[UIView beginAnimations:@"progressAppearAnimation" context:nil];
	[UIView setAnimationDelay:0.5f];
	
	self.progressView.progress = 0.0f;
	self.progressView.alpha = 1.0f;
	
	[UIView commitAnimations];
}

- (void) removeProgressAnimated
{
	[UIView beginAnimations:@"progressDisappearAnimation" context:nil];
	[UIView setAnimationDelay:0.5f];					
	
	self.progressView.alpha = 0.0f;

	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Actions

- (IBAction) radiusChanged:(id)sender
{
	CGFloat value = radiusSlider_.value;
	imageView_.radius = value;
}

- (IBAction) widthChagned:(id)sender
{
	CGFloat value = widthSlider_.value;
	imageView_.width = value;
}

@end
