//
// RSKExampleViewController.m
//
// Copyright (c) 2014-present Ruslan Skorb, http://ruslanskorb.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RSKExampleViewController.h"
#import "RSKImageCropper.h"
#import "RSKImageCropperExample-Swift.h"

static const CGFloat kPhotoDiameter = 130.0f;
static const CGFloat kPhotoFrameViewPadding = 2.0f;

@interface RSKExampleViewController () <RSKImageCropViewControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIView *photoFrameView;
@property (strong, nonatomic) UIView *photoFrameView2;
@property (strong, nonatomic) UIButton *addPhotoButton;
@property (strong, nonatomic) UIButton *addPhotoButton2;
@property (assign, nonatomic) BOOL didSetupConstraints;
@property (assign, nonatomic) CGRect zoomToRect;
@property (assign, nonatomic) BOOL doZoom;
@property (assign, nonatomic) BOOL imagePicked;

@end

@implementation RSKExampleViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = @"RSKImageCropper";
    
    // ---------------------------
    // Add the frame of the photo.
    // ---------------------------
    
    self.photoFrameView = [[UIView alloc] init];
    self.photoFrameView.backgroundColor = [UIColor colorWithRed:182/255.0f green:182/255.0f blue:187/255.0f alpha:1.0f];
    self.photoFrameView.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoFrameView.layer.masksToBounds = YES;
    self.photoFrameView.layer.cornerRadius = (kPhotoDiameter + kPhotoFrameViewPadding) / 2;
    [self.view addSubview:self.photoFrameView];
    
    self.photoFrameView2 = [[UIView alloc] init];
    self.photoFrameView2.backgroundColor = [UIColor colorWithRed:182/255.0f green:182/255.0f blue:187/255.0f alpha:1.0f];
    self.photoFrameView2.translatesAutoresizingMaskIntoConstraints = NO;
    self.photoFrameView2.layer.masksToBounds = YES;
    self.photoFrameView2.layer.cornerRadius = (kPhotoDiameter + kPhotoFrameViewPadding) / 2;
    [self.view addSubview:self.photoFrameView2];
    
    // ---------------------------
    // Add the button "add photo".
    // ---------------------------
    
    self.addPhotoButton = [[UIButton alloc] init];
    self.addPhotoButton.backgroundColor = [UIColor whiteColor];
    self.addPhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.addPhotoButton.layer.masksToBounds = YES;
    self.addPhotoButton.layer.cornerRadius = kPhotoDiameter / 2;
    self.addPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.addPhotoButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addPhotoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.addPhotoButton setTitle:@"add\nphoto" forState:UIControlStateNormal];
    [self.addPhotoButton setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.addPhotoButton addTarget:self action:@selector(onAddPhotoButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPhotoButton];
    
    self.addPhotoButton2 = [[UIButton alloc] init];
    self.addPhotoButton2.backgroundColor = [UIColor whiteColor];
    self.addPhotoButton2.translatesAutoresizingMaskIntoConstraints = NO;
    self.addPhotoButton2.layer.masksToBounds = YES;
    self.addPhotoButton2.layer.cornerRadius = kPhotoDiameter / 2;
    self.addPhotoButton2.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.addPhotoButton2.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addPhotoButton2.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.addPhotoButton2 setTitle:@"add\nphoto\n+\nzoom" forState:UIControlStateNormal];
    [self.addPhotoButton2 setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.addPhotoButton2 addTarget:self action:@selector(onAddPhotoButtonTouch2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPhotoButton2];
    
    // ----------------
    // Add constraints.
    // ----------------
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.didSetupConstraints) {
        return;
    }
    
    // ---------------------------
    // The frame of the photo.
    // ---------------------------
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:(kPhotoDiameter + kPhotoFrameViewPadding)];
    [self.photoFrameView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:(kPhotoDiameter + kPhotoFrameViewPadding)];
    [self.photoFrameView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:(kPhotoDiameter + kPhotoFrameViewPadding)];
    [self.photoFrameView2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:(kPhotoDiameter + kPhotoFrameViewPadding)];
    [self.photoFrameView2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:150.0f];
    [self.view addConstraint:constraint];
    
    // ---------------------------
    // The button "add photo".
    // ---------------------------
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kPhotoDiameter];
    [self.addPhotoButton addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kPhotoDiameter];
    [self.addPhotoButton addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.photoFrameView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.photoFrameView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self.view addConstraint:constraint];
 
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton2 attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kPhotoDiameter];
    [self.addPhotoButton2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton2 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kPhotoDiameter];
    [self.addPhotoButton2 addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton2 attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.photoFrameView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton2 attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.photoFrameView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:150.0f];
    [self.view addConstraint:constraint];
    
    self.didSetupConstraints = YES;
}

#pragma mark - Action handling

- (void)onAddPhotoButtonTouch:(UIButton *)sender {
    self.zoomToRect = CGRectZero;
    self.doZoom = false;
    self.imagePicked = false;

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
//    [self imagePickerController:nil didFinishPickingMediaWithInfo:nil];
}

- (void)onAddPhotoButtonTouch2:(UIButton *)sender {
    self.zoomToRect = CGRectZero;
    self.doZoom = true;
    self.imagePicked = false;

    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
//    [self imagePickerController:nil didFinishPickingMediaWithInfo:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (self.imagePicked) {
        return;
    }
    self.imagePicked = true;

    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //UIImage *image = [UIImage imageNamed:@"photo"];

    if (@available(iOS 11.0, *)) {
        if (self.doZoom) {
            FaceDetector *fd = [[FaceDetector alloc] initWithImage:image faceDetectedHandler:^(CGRect rect) {
                self.zoomToRect = rect;
                
                RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
                imageCropVC.delegate = self;
                
                [self.navigationController pushViewController:imageCropVC animated:YES];
            }];
            
            [fd detectFace];
            
            return;
        }
    }

    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle]; // RSKImageCropModeCustom
    imageCropVC.delegate = self;
    
    [self.navigationController pushViewController:imageCropVC animated:YES];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidDisplayImage:(RSKImageCropViewController *)controller {
    if (!CGRectIsEmpty(self.zoomToRect)) {
        NSLog(@"Zooming to %f, %f, %f, %f", self.zoomToRect.origin.x, self.zoomToRect.origin.y, self.zoomToRect.size.width, self.zoomToRect.size.height);

        [controller zoomToRect:self.zoomToRect animated:YES];
    }
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle {
    if (self.doZoom) {
        [self.addPhotoButton2 setImage:croppedImage forState:UIControlStateNormal];
    } else {
        [self.addPhotoButton setImage:croppedImage forState:UIControlStateNormal];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
