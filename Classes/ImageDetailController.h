//
//  ServiceDetailController.h
//  iPhoneClient
//
//	HW7
//
//  portions Copyright 2010 Chris Parrish

#import <UIKit/UIKit.h>

// HW_TODO :
//
// YOU CAN USE MY CONTROLLER CLASS
// OR YOUR OWN. IF YOU WANT TO USE YOUR OWN
// YOU'LL NEED TO LOOK AT THE CODE IN THIS CLASS
// THAT HANDLES THE IMAGE TRANSFER 
// AND REPLICATE SOMETHING SIMILAR IN YOUR CONTROLLER

@class FramedImageView;

@interface ImageDetailController : UIViewController
{
	
	NSNetService*		service_;
	
	NSOutputStream*		outputStream_;
	// Output stream is how we could send messages back to the service
	NSInputStream*		inputStream_;
	// Input stream is where we recieve image data from the service
	
	NSMutableData*		currentImageData_;
	// This is where we keep the data we are receving form the network

	NSUInteger			currentImageDataSize_;
	// The first data we get from the service is a four-byte integer
	// that is the size of the image data to follow
	
	FramedImageView*	imageView_;
	UISlider*			radiusSlider_;
	UISlider*			widthSlider_;	
	UIProgressView*		progressView_;
	
}

@property (nonatomic, retain)			NSNetService*		service;
@property (nonatomic, retain) IBOutlet	FramedImageView*	imageView;
@property (nonatomic, retain) IBOutlet	UISlider*			radiusSlider;
@property (nonatomic, retain) IBOutlet	UISlider*			widthSlider;
@property (nonatomic, retain) IBOutlet  UIProgressView*		progressView;

- (IBAction) radiusChanged:(id)sender;
- (IBAction) widthChagned:(id)sender;

@end
