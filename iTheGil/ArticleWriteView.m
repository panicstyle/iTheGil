//
//  ArticleWriteView.m
//  iGongdong
//
//  Created by dykim on 2016. 3. 3..
//  Copyright © 2016년 dykim. All rights reserved.
//

#import <Photos/Photos.h>
#import "ArticleWriteView.h"
#import "Utils.h"

@interface ArticleWriteView ()
{
	int m_bUpMode;
	long m_lContentHeight;
	UIAlertView *alertWait;
	
	int m_selectedImage;
	int m_ImageStatus[5];
	int m_nAttachCount;
	NSString *m_strImageFileName[5];
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
@synthesize viewTitle;
@synthesize viewContent;
@synthesize viewImage0;
@synthesize viewImage1;
@synthesize viewImage2;
@synthesize viewImage3;
@synthesize viewImage4;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	m_bUpMode = false;
	
	if ([m_nMode intValue] == ArticleWrite) {
		[(UILabel *)self.navigationItem.titleView setText:@"글쓰기"];
	} else if ([m_nMode intValue] == ArticleModify) {
		[(UILabel *)self.navigationItem.titleView setText:@"글수정"];
		viewTitle.text = m_strTitle;
		viewContent.text = m_strContent;
		
		// 수정때는 먼저 편집창을 호출해야 함. 그렇지 않을 경우 정상적으로 수정하지 않았다는 오류 발생
		[self requestEditPage];
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
	
	viewImage0.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage1.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage2.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage3.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	viewImage4.image = [UIImage imageNamed:@"ic_image_white_18pt"];
	m_ImageStatus[0] = 0;
	m_ImageStatus[1] = 0;
	m_ImageStatus[2] = 0;
	m_ImageStatus[3] = 0;
	m_ImageStatus[4] = 0;
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
	NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
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
	
	CGRect contentRect = viewContent.frame;
	contentRect.size.height = contentRect.size.height + movement;
	viewContent.frame = contentRect;
	
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

- (void) cancelEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void) requestEditPage
{
	NSString *url = [NSString stringWithFormat:@"%@/2014/bbs/write.php?w=u&bo_table=%@&wr_id=%@&page=", WWW_SERVER, m_strBoardId, m_strBoardNo];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
	NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:NSUTF8StringEncoding];
	
	NSLog(@"requestEditPage = %@", str);
}

- (void) doneEditing:(id)sender
{
	//	[contentView resignFirstResponder];
	////NSLog(@"donEditing start...");
	NSString *url;
	
	if (viewTitle.text.length <= 0 || viewContent.text.length <= 0) {
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
	NSString *strReferer = [NSString stringWithFormat:@"http://thegil.org/2014/bbs/write.php?w=u&bo_table=%@&wr_id=%@&page=", m_strBoardId, m_strBoardNo];
	
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
	[request addValue:strReferer forHTTPHeaderField: @"Referer"];
	
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
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uid\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", dateString] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// w
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"w\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", strWmode] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// botable
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bo_table\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", m_strBoardId] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_id
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", m_strBoardNo] dataUsingEncoding:NSUTF8StringEncoding]];

	// sca
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sca\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", strSCA] dataUsingEncoding:NSUTF8StringEncoding]];

	// sfl
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sfl\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// stx
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"stx\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// spt
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"spt\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// sst
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sst\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// sod
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sod\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// page
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"page\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", strPage] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// html
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"html\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"html1\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_subject
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_subject\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", viewTitle.text] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_content
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_content\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"%@\r\n", viewContent.text] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_link1
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_link1\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// wr_link2
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"wr_link2\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	int i = 0;
	m_nAttachCount = 0;
	for (i = 0; i < 5; i++) {
		if (m_ImageStatus[i] == 1) {
			// file - 1
			NSData *imageData;
			if (i == 0) {
				imageData = UIImagePNGRepresentation([self scaleToFitWidth:[viewImage0 image] width:SCALE_SIZE]);
			} else if (i == 1) {
				imageData = UIImagePNGRepresentation([self scaleToFitWidth:[viewImage1 image] width:SCALE_SIZE]);
			} else if (i == 2) {
				imageData = UIImagePNGRepresentation([self scaleToFitWidth:[viewImage2 image] width:SCALE_SIZE]);
			} else if (i == 3) {
				imageData = UIImagePNGRepresentation([self scaleToFitWidth:[viewImage3 image] width:SCALE_SIZE]);
			} else if (i == 4) {
				imageData = UIImagePNGRepresentation([self scaleToFitWidth:[viewImage4 image] width:SCALE_SIZE]);
			}
			
			[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"%@\"\r\n", m_strImageFileName[i]] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:imageData];
			[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			m_nAttachCount++;
		} else {
			// file blank
			[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"bf_file[]\"; filename=\"\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}

	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSString *strCheck = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
	NSLog(@"strCheck = %@", strCheck);
	
	[request setHTTPBody:body];
	
	respData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	NSString *str = [[NSString alloc] initWithData:respData
										  encoding:NSUTF8StringEncoding];
	if ([Utils numberOfMatches:str regex:@"<title>오류안내 페이지"] > 0) {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	//You can retrieve the actual UIImage
	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	//Or you can get the image url from AssetsLibrary
	NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
	PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[path] options:nil];
	NSString *filename = [[result firstObject] filename];
	
	if (m_selectedImage == 0) {
		viewImage0.image = image;
		m_ImageStatus[0] = 1;
		m_strImageFileName[0] = filename;
	} else if (m_selectedImage == 1) {
		viewImage1.image = image;
		m_ImageStatus[1] = 1;
		m_strImageFileName[1] = filename;
	} else if (m_selectedImage == 2) {
		viewImage2.image = image;
		m_ImageStatus[2] = 1;
		m_strImageFileName[2] = filename;
	} else if (m_selectedImage == 3) {
		viewImage3.image = image;
		m_ImageStatus[3] = 1;
		m_strImageFileName[3] = filename;
	} else if (m_selectedImage == 4) {
		viewImage4.image = image;
		m_ImageStatus[4] = 1;
		m_strImageFileName[4] = filename;
	}
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int imageStatus;
	UIImageView *viewImage;
	if ([touch view] == viewImage0) {
		NSLog(@"viewImage1 touched");
		m_selectedImage = 0;
		imageStatus = m_ImageStatus[0];
		viewImage = viewImage0;
	} else if ([touch view] == viewImage1) {
		NSLog(@"viewImage2 touched");
		m_selectedImage = 1;
		imageStatus = m_ImageStatus[1];
		viewImage = viewImage1;
	} else if ([touch view] == viewImage2) {
		NSLog(@"viewImage3 touched");
		m_selectedImage = 2;
		imageStatus = m_ImageStatus[2];
		viewImage = viewImage2;
	} else if ([touch view] == viewImage3) {
		NSLog(@"viewImage4 touched");
		m_selectedImage = 3;
		imageStatus = m_ImageStatus[3];
		viewImage = viewImage3;
	} else if ([touch view] == viewImage4) {
		NSLog(@"viewImage5 touched");
		m_selectedImage = 4;
		imageStatus = m_ImageStatus[4];
		viewImage = viewImage4;
	}
	if (imageStatus == 0) {
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.delegate = self;
		[self presentViewController:imagePickerController animated:YES completion:nil];
	} else {
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
																	   message:@"삭제하시겠습니까?"
																preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction * action) {
															 [self DeleteImage];
														 }];
		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
															 handler:^(UIAlertAction * action) {}];
		
		
		[alert addAction:okAction];
		[alert addAction:cancelAction];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)DeleteImage {
	if (m_selectedImage == 0) {
		viewImage0.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[0] = 0;
	} else if (m_selectedImage == 1) {
		viewImage1.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[1] = 0;
	} else if (m_selectedImage == 2) {
		viewImage2.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[2] = 0;
	} else if (m_selectedImage == 3) {
		viewImage3.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[3] = 0;
	} else if (m_selectedImage == 4) {
		viewImage4.image = [UIImage imageNamed:@"ic_image_white_18pt"];
		m_ImageStatus[4] = 0;
	}
}

-(UIImage *)scaleToFitWidth:(UIImage *)image width:(CGFloat)width
{
	if (image.size.width <= SCALE_SIZE) return image;
	
	CGFloat ratio = width / image.size.width;
	CGFloat height = image.size.height * ratio;
	
	NSLog(@"W:%f H:%f",width,height);
	
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	[image drawInRect:CGRectMake(0.0f,0.0f,width,height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
