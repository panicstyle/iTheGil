//
//  NewView.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "NewView.h"
#import "env.h"
#import "LoginToService.h"
#import "ArticleView.h"
#import "NewData.h"

@interface NewView ()
{
	NSMutableArray *m_arrayItems;
	NSString *m_strTitle;
	int m_nPage;
	NewData *m_newData;
	NSNumber *m_nItemMode;

	CGRect m_rectScreen;
}
@end

@implementation NewView

@synthesize m_strBoardId;
@synthesize m_nMode;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	m_rectScreen = [self getScreenFrameForCurrentOrientation];
	
	// Replace this ad unit ID with your own ad unit ID.
	self.bannerView.adUnitID = kSampleAdUnitID;
	self.bannerView.rootViewController = self;
	
	GADRequest *request = [GADRequest request];
	// Requests test ads on devices you specify. Your test device ID is printed to the console when
	// an ad request is made. GADBannerView automatically returns test ads when running on a
	// simulator.
	request.testDevices = @[
							@"2077ef9a63d2b398840261c8221a0c9a"  // Eric's iPod Touch
							];
	[self.bannerView loadRequest:request];
	
	m_nItemMode = [NSNumber numberWithInt:NormalItems];
	
	m_arrayItems = [[NSMutableArray alloc] init];
	
	m_newData = [[NewData alloc] init];
	m_newData.m_strBoardId = m_strBoardId;
	m_newData.m_nMode = m_nMode;
	m_newData.target = self;
	m_newData.selector = @selector(didFetchItems:);
	m_nPage = 1;
	[m_newData fetchItems:m_nPage];

	
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"count = %lu", (unsigned long)[m_arrayItems count]);
	// 더보기를 표시하기 위하여 +1
	if ([m_arrayItems count] > 0) {
		return [m_arrayItems count] + 1;
	} else {
		return [m_arrayItems count];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] == [m_arrayItems count]) {
		return 50.0f;
	} else {
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
		NSNumber *height = [item valueForKey:@"height"];
		return [height floatValue];
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifierMore = @"More";
	static NSString *CellIdentifierItem = @"Item";
	
	UITableViewCell *cell;
	if ([indexPath row] == [m_arrayItems count]) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMore];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMore];
		}
		// 더보기 표시
		CGRect tRect1 = CGRectMake(0.0f, 0.0f, 320.0f, 44.0f);
		id title1 = [[UILabel alloc] initWithFrame:tRect1];
		[title1 setText:@"더  보  기"];
		[title1 setTextAlignment:NSTextAlignmentCenter];
		[title1 setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
		[title1 setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
		[title1 setBackgroundColor:[UIColor clearColor]];
		[cell addSubview:title1];
		return cell;
	} else {
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:[indexPath row]];
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierItem];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierItem];
		}
//				cell.showsReorderControl = YES;
		
		UILabel *lableBoard = (UILabel *)[cell viewWithTag:102];
		NSString *strGroup = [item valueForKey:@"group"];
		NSString *strBoard = [item valueForKey:@"board"];
		NSString *strBoardName = [NSString stringWithFormat:@"%@ %@", strGroup, strBoard];
		
		NSMutableAttributedString *textBoard = [[NSMutableAttributedString alloc] initWithString:strBoardName];
		[textBoard addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, [strBoardName length])];
		lableBoard.attributedText = textBoard;
		
		UILabel *labelName = (UILabel *)[cell viewWithTag:100];
		NSString *strName = [item valueForKey:@"name"];
		NSString *strDate = [item valueForKey:@"date"];
		NSString *strNameDate = [NSString stringWithFormat:@"%@  %@", strName, strDate];
		
		NSMutableAttributedString *textName = [[NSMutableAttributedString alloc] initWithString:strNameDate];
		[textName addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange([strName length] + 2, [strDate length])];
		labelName.attributedText = textName;
		
		UITextView *textSubject = (UITextView *)[cell viewWithTag:101];
		textSubject.text = [item valueForKey:@"subject"];
		
		//			CGFloat textViewWidth = viewComment.frame.size.width;
		UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
		CGFloat textViewWidth;
		switch (orientation) {
			case UIDeviceOrientationUnknown:
			case UIDeviceOrientationPortrait:
			case UIDeviceOrientationPortraitUpsideDown:
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
				textViewWidth = m_rectScreen.size.width - 32 - 20;
				break;
			case UIDeviceOrientationLandscapeLeft:
			case UIDeviceOrientationLandscapeRight:
				textViewWidth = m_rectScreen.size.height - 32 - 20;
		}
		
		CGSize size = [textSubject sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
		float height = (100 - 32) + (size.height);
		[item setObject:[NSNumber numberWithFloat:height] forKey:@"height"];
		NSLog(@"row = %ld, width=%f, height=%f", (long)[indexPath row], textViewWidth, height);
	}
	return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == [m_arrayItems count]) {
		// 더보기를 수행한다.
		//		[arrayItems release];
		m_nPage++;
		
		[m_newData fetchItems:m_nPage];
	}
	
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"Article"]) {
		ArticleView *view = [segue destinationViewController];
		NSIndexPath *currentIndexPath = [self.tbView indexPathForSelectedRow];
		long row = currentIndexPath.row;
		NSMutableDictionary *item = [m_arrayItems objectAtIndex:row];
		view.m_strBoardId = [item valueForKey:@"boardId"];
		view.m_strBoardNo = [item valueForKey:@"boardNo"];
		view.target = self;
		view.selector = @selector(didWrite:);
	}
}

#pragma mark - Screen Function

- (CGRect)getScreenFrameForCurrentOrientation {
	return [self getScreenFrameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (CGRect)getScreenFrameForOrientation:(UIInterfaceOrientation)orientation {
	
	CGRect fullScreenRect = [[UIScreen mainScreen] bounds];
	
	// implicitly in Portrait orientation.
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		CGRect temp = CGRectZero;
		temp.size.width = fullScreenRect.size.height;
		temp.size.height = fullScreenRect.size.width;
		fullScreenRect = temp;
	}
	
	CGFloat statusBarHeight = 20; // Needs a better solution, FYI statusBarFrame reports wrong in some cases..
	fullScreenRect.size.height -= statusBarHeight;
	fullScreenRect.size.height -= self.navigationController.navigationBar.frame.size.height;
	fullScreenRect.size.height -= 40 + 40;
	
	return fullScreenRect;
}

#pragma mark Data Function

- (void)didFetchItems:(NSNumber *)result
{
	if (m_nPage == 1) {
		m_nItemMode = m_newData.m_nItemMode;
		m_arrayItems = m_newData.m_arrayItems;
	} else {
		[m_arrayItems addObjectsFromArray:m_newData.m_arrayItems];
	}
	[self.tbView reloadData];
}

- (void)didWrite:(id)sender
{
	NSLog(@"didWrite");
	
	[m_arrayItems removeAllObjects];
	[self.tbView reloadData];
	
	m_nPage = 1;
	
	[m_newData fetchItems:1];
	
}

@end
