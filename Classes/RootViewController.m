//
//  RootViewController.m
//  iPhoneClient
//
//	HW7
//
//  portions Copyright 2010 Chris Parrish

#import "RootViewController.h"
#import "ImageDetailController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#include <netdb.h>

NSString* const			kServiceTypeString		= @"_uwcelistener._tcp.";
NSString* const			kSearchDomain			= @"";
// Bonjour automatically puts everything in the .local domain,
// ie your mac is something like MyMacSharingName.local
// using an empty search domain will result in all the default domains
// including .local and Back to My Mac

@implementation RootViewController


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc
{
	[services_ release];
    [super dealloc];
}


#pragma mark -
#pragma mark NSNetService

- (void) startServiceSearch
{
    browser_		= [[NSNetServiceBrowser alloc] init];
    [browser_ setDelegate:self];
    [browser_ searchForServicesOfType:kServiceTypeString inDomain:kSearchDomain];
		
	NSLog(@"Started browsing for services: %@", [browser_ description]);	
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing
{
	NSLog(@"Found domain : %@", domainName);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser 
           didFindService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing 
{
    NSLog(@"Adding new service");
    [services_ addObject:aNetService];
   
	[aNetService setDelegate:self];
    [aNetService resolveWithTimeout:5.0];
	// timeout is in seconds
	
    if (!moreComing)
	{
        [self.tableView reloadData];        
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser 
         didRemoveService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing 
{
    NSLog(@"Removing service");
	
	for (NSNetService* currentNetService in services_)
	{
		if ([[currentNetService name] isEqual:[aNetService name]] && 
			[[currentNetService type] isEqual:[aNetService type]] && 
			[[currentNetService domain] isEqual:[aNetService domain]])
		{
            [services_ removeObject:currentNetService];
            break;
        }
		
	}
    if (!moreComing)
	{
        [self.tableView reloadData];        
    }
}

- (void)netServiceWillResolve:(NSNetService *)sender
{
	NSLog(@"RESOLVING net service with name %@ and type %@", [sender name], [sender type]);
}


- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"RESOLVED net service with name %@ and type %@", [sender name], [sender type]);
	[self.tableView reloadData];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"DID NOT RESOLVE net service with name %@ and type %@", [sender name], [sender type]);
	NSLog(@"Error Dict:", [errorDict description]);
	
	NSUInteger indexOfService = [services_ indexOfObject:sender];
	
	if ( indexOfService != NSNotFound )
	{
		NSIndexPath* path = [NSIndexPath indexPathForRow:indexOfService inSection:1];
		UITableViewCell* failureCell = [self tableView:self.tableView cellForRowAtIndexPath:path];
		failureCell.textLabel.text = @"Failed to resolve address";
	}
}




#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    services_		= [[NSMutableArray array] retain];
	[self startServiceSearch];
		// start looking for services that may be available
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [services_ count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSNetService* service = [services_ objectAtIndex:indexPath.row];
	NSArray* addresses = [service addresses];
	
	if ([addresses count] == 0)
	{
		cell.textLabel.text = @"Could not resolve address";
	}
	else
	{
		cell.textLabel.text = [service hostName];
	}
	
	
	for (NSData* addressData in addresses)
	{
		struct sockaddr_in* address = (struct sockaddr_in*)[addressData bytes];	
		
		NSLog(@"host : %d port : %d", ntohl(address->sin_addr.s_addr), ntohs(address->sin_port));
		
		char hostname[2048];
		char serv[20];
		
		getnameinfo((const struct sockaddr*)address, sizeof(address), hostname, sizeof(hostname), serv, sizeof(serv), 0);
		
		NSLog(@"hostname : %s service : %s", hostname, serv);
		
		NSLog(@"domain : %@", [service domain]);
	}
	
	
	cell.detailTextLabel.text = [service name]; 
	
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	// if the selection was not resolved, try to resolve it again, but don't attempt
	// to bring up the details
	
	NSNetService* selectedService = [services_ objectAtIndex:indexPath.row];
	
	if ( [[selectedService addresses] count] <= 0 )
	{
		UITableViewCell* selectedCell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
		selectedCell.textLabel.text = @"Attempting to resolve address";
		[selectedService resolveWithTimeout:5.0];
	}
	
    ImageDetailController* detailController = [[ImageDetailController alloc] initWithNibName:@"ServiceDetailController" bundle:nil];
	
	detailController.service = selectedService;
    [[self navigationController] pushViewController:detailController animated:YES];
    [detailController release];	
}




@end

