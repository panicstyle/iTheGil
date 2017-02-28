//
//  ArticleWriteView.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import "ArticleWriteView.h"
#import "Utils.h"

@interface ArticleWriteView ()
{
	int m_bUpMode;
	UITextField *m_titleField;
	UITextView *m_contentView;
	long m_lContentHeight;
	UITableViewCell *m_contentCell;
	UITableViewCell *m_imageCell;
	int m_nAddPic;
}

@end

@implementation ArticleWriteView
@synthesize m_nMode;
@synthesize m_strBoardId;
@synthesize m_strBoardNo;
@synthesize m_strTitle;
@synthesize m_strContent;
@synthesize target;
@synthesize selector;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	m_bUpMode = false;
	m_nAddPic = false;
	
	if ([m_nMode intValue] == ArticleWrite) {
		[(UILabel *)self.navigationItem.titleView setText:@"글쓰기"];
	} else if ([m_nMode intValue] == ArticleModify) {
		[(UILabel *)self.navigationItem.titleView setText:@"글수정"];
	}

	CGRect rectScreen = [self getScreenFrameForCurrentOrientation];
	m_lContentHeight = rectScreen.size.height;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithTitle:@"완료"
											   style:UIBarButtonItemStyleDone
											   target:self
											   action:@selector(doneEditing:)];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
											  initWithTitle:@"취소"
											  style:UIBarButtonItemStylePlain
											  target:self
											  action:@selector(cancelEditing:)];

	// Listen for keyboard appearances and disappearances
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification
											   object:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)keyboardDidShow: (NSNotification *) notif{
	// Do something here
	[self animateTextView:notif up:YES];
}

- (void)keyboardDidHide: (NSNotification *) notif{
	// Do something here
	[self animateTextView:notif up:NO];
}

-(void)animateTextView:(NSNotification *)notif up:(BOOL)up
{
	if (m_bUpMode == up) return;
	
	NSDictionary* keyboardInfo = [notif userInfo];
	NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
	CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
	
	const int movementDistance = keyboardFrameBeginRect.size.height; // tweak as needed
	const float movementDuration = 0.3f; // tweak as needed
	
	int movement = (up ? -movementDistance : movementDistance);

	[UIView beginAnimations: @"animateTextView" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: movementDuration];
	
	CGRect viewRect = self.view.frame;
	viewRect.size.height = viewRect.size.height + movement;
	self.view.frame = viewRect;
	
//	CGRect tableRect = self.tbView.frame;
//	tableRect.size.height = tableRect.size.height + movement;
//	self.tbView.frame = tableRect;
	
	CGRect contentRect = m_contentCell.frame;
	contentRect.size.height = contentRect.size.height + movement;
	m_contentCell.frame = contentRect;

	[self.tbView beginUpdates];
	[self.tbView endUpdates];
	
//	CGRect textRect = m_contentView.frame;
//	textRect.size.height = textRect.size.height + movement;
//	m_contentView.frame = textRect;
	
//	CGRect imageRect = m_imageCell.frame;
//	imageRect.size.height = imageRect.size.height;
//	m_imageCell.frame = imageRect;

	[UIView commitAnimations];
	m_bUpMode = up;
}

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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath row] == 0) {
		return 40.0f;
	} else if ([indexPath row] == 1) {
		return (float)m_lContentHeight;
	} else {
		return 40.0f;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifierTitle = @"Title";
	static NSString *CellIdentifierContent = @"Content";
	static NSString *CellIdentifierImage = @"Image";
	
	UITableViewCell *cell;
	if ([indexPath row] == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierTitle];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierTitle];
		}
		m_titleField = (UITextField *)[cell viewWithTag:100];
		m_titleField.text = m_strTitle;
		return cell;
	} else if ([indexPath row] == 1){
		m_contentCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierContent];
		if (m_contentCell == nil) {
			m_contentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierContent];
		}
		m_contentView = (UITextView *)[m_contentCell viewWithTag:101];
		m_contentView.text = m_strContent;
		return m_contentCell;
	} else {
		m_imageCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierImage];
		if (m_imageCell == nil) {
			m_imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierImage];
		}
		m_imageCell.textLabel.text = @"Image Line";
		return m_imageCell;
	}
}


- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void) doneEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	////NSLog(@"donEditing start...");
	NSString *url;
	
	if (m_titleField.text.length <= 0 || m_contentView.text.length <= 0) {
		// 쓰여진 내용이 없으므로 저장하지 않는다.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"확인"
														message:@"입력된 내용이 없습니다."
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:nil];
		[alert addButtonWithTitle:@"확인"];
		[alert show];
		return;
	}
	
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyMMddHHmmssSSSS"];
	NSString *dateString = [dateFormat stringFromDate:today];
	NSLog(@"date: %@", dateString);
	
	//		/cafe.php?mode=up&sort=354&p1=tuntun&p2=HTTP/1.1
	url = [NSString stringWithFormat:@"%@/2014/bbs/write_update.php", WWW_SERVER];
	
	NSData *respData;

	// 사진첨부됨, Multipart message로 전송
	//        NSData *imageData = UIImagePNGRepresentation(addPicture.image);
//	NSData *imageData = UIImageJPEGRepresentation(addPicture.image, 0.5f);
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"POST"];
	
	NSString *boundary = @"0xKhTmLbOuNdArY";  // important!!!
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	NSMutableData *body = [NSMutableData data];
	
	NSString *strWmode = @"";
	NSString *strSCA = @"";
	NSString *strPage = @"";
	if ([m_nMode intValue] == ArticleWrite) {
		strWmode = @"";
		m_strBoardNo = @"0";
	} else if ([m_nMode intValue] == ArticleModify) {
		strWmode = @"u";
		strPage = @"0";
	} else if ([m_nMode intValue] == ArticleReply) {
		strWmode = @"r";
	}
	if ([m_strBoardId isEqualToString:@"B13"]) {
		strSCA = @"문서자료";
	}

	// uid
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", dateString] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// w
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"w\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", strWmode] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// botable
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bo_table\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", m_strBoardId] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_id
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_id\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", m_strBoardNo] dataUsingEncoding:NSUTF8StringEncoding]];

	// sca
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sca\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", strSCA] dataUsingEncoding:NSUTF8StringEncoding]];

	// sfl
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sfl\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// stx
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"stx\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// spt
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"spt\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// sst
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sst\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// sod
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sod\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// page
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", strPage] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// html
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"html\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"html1\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_subject
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_subject\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", m_titleField.text] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_content
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_content\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\n", m_contentView.text] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_link1
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_link1\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_link2
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_link2\"\n\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// file - 1
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"\"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// file - 2
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"\"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// file - 3
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"\"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// file - 4
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"\"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// file - 5
	[body appendData:[[NSString stringWithFormat:@"--%@\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"\"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[body appendData:[[NSString stringWithFormat:@"--%@--\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSString *strCheck = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
	NSLog(@"strCheck = %@", strCheck);
	
	[request setHTTPBody:body];
	
	respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:NSUTF8StringEncoding];
	if ([Utils numberOfMatches:str regex:@"history.back"] > 0) {
		NSString *errmsg;
		errmsg = [Utils findStringRegex:str regex:@"(<p class=\\\"cbg\\\">).*?(</p>)"];
		errmsg = [Utils replaceStringHtmlTag:errmsg];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"글 작성 오류"
														message:errmsg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
		[alert show];
	} else {
		NSLog(@"write article success");
		[target performSelector:selector withObject:nil afterDelay:0];
		[[self navigationController] popViewControllerAnimated:YES];
	}
}

@end
