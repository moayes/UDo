//
//  RWCollectionViewController.m
//  UDo
//
//  Created by Soheil Azarpour on 12/21/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "RWCollectionViewController.h"
#import "RWCollectionViewCell.h"
#import "UIAlertView+RWBlock.h"

@interface RWCollectionViewController ()

/** @brief An array of NSString objects, data source of the collection view. */
@property (strong, nonatomic) NSMutableArray *objects;

@end

@implementation RWCollectionViewController

#pragma mark - Custom accessors

- (NSMutableArray *)objects {
  if (!_objects) {
    _objects = [@[@"Get Milk!", @"Go to gym", @"Breakfast with Rita!", @"Call Bob", @"Pick up newspaper", @"Send an email to Joe", @"Read this tutorial!", @"Pick up flowers"] mutableCopy];
  }
  return _objects;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
  self.title = @"To Do!";
  
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
  [self.collectionView addGestureRecognizer:longPress];
  
  [super viewDidLoad];
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.objects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kIdentifier = @"Cell Identifier";
  
  RWCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIdentifier forIndexPath:indexPath];
  
  // Update cell content from data source.
  NSString *object = self.objects[indexPath.row];
  cell.backgroundColor = [UIColor whiteColor];
  cell.textLabel.text = object;
  
  return cell;
}

#pragma mark - IBActions

- (IBAction)addButtonPressed:(id)sender {
  
  // Display an alert view with a text input.
  UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"Add a new to-do item:" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Add", nil];
  
  inputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  
  __weak RWCollectionViewController *weakself = self;
  
  // Add a completion block (using our category to UIAlertView).
  [inputAlertView setCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    
    // If user pressed 'Add'...
    if (buttonIndex == 1) {
      
      UITextField *textField = [alertView textFieldAtIndex:0];
      NSString *string = [textField.text capitalizedString];
      [weakself.objects addObject:string];
      
      NSUInteger row = [weakself.objects count] - 1;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      [weakself.collectionView insertItemsAtIndexPaths:@[indexPath]];
    }
  }];
  
  [inputAlertView show];
}

- (IBAction)longPressGestureRecognized:(id)sender {
  
  UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
  UIGestureRecognizerState state = longPress.state;
  
  CGPoint location = [longPress locationInView:self.collectionView];
  NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
  
  static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
  static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
  
  switch (state) {
    case UIGestureRecognizerStateBegan: {
      if (indexPath) {
        sourceIndexPath = indexPath;
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        // Take a snapshot of the selected row using helper method.
        snapshot = [self customSnapshoFromView:cell];
        
        // Add the snapshot as subview, centered at cell's center...
        __block CGPoint center = cell.center;
        snapshot.center = center;
        snapshot.alpha = 0.0;
        [self.collectionView addSubview:snapshot];
        [UIView animateWithDuration:0.25 animations:^{
          
          // Offset for gesture location.
          center.y = location.y;
          snapshot.center = center;
          snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
          snapshot.alpha = 0.98;
          
          // Fade out.
          cell.alpha = 0.0;
        } completion:nil];
      }
      break;
    }
      
    case UIGestureRecognizerStateChanged: {
      CGPoint center = snapshot.center;
      center.y = location.y;
      snapshot.center = center;
      
      // Is destination valid and is it different from source?
      if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
        
        // ... update data source.
        [self.objects exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
        
        // ... move the rows.
        [self.collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:indexPath];
        
        // ... and update source so it is in sync with UI changes.
        sourceIndexPath = indexPath;
      }
      break;
    }
      
    default: {
      // Clean up.
      UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:sourceIndexPath];
      [UIView animateWithDuration:0.25 animations:^{
        
        snapshot.center = cell.center;
        snapshot.transform = CGAffineTransformIdentity;
        snapshot.alpha = 0.0;
        
        // Undo the fade-out effect we did.
        cell.alpha = 1.0;
        
      } completion:^(BOOL finished) {
        
        [snapshot removeFromSuperview];
        snapshot = nil;
        
      }];
      sourceIndexPath = nil;
      break;
    }
  }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
  
  // Make an image from the input view.
  UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
  [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  // Create an image view.
  UIView *snapshot = [[UIImageView alloc] initWithImage:image];
  snapshot.layer.masksToBounds = NO;
  snapshot.layer.cornerRadius = 0.0;
  snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
  snapshot.layer.shadowRadius = 5.0;
  snapshot.layer.shadowOpacity = 0.4;
  
  return snapshot;
}

@end
