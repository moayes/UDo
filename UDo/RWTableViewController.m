//
//  RWTableViewController.m
//  UDo
//
//  Created by Soheil Azarpour on 12/21/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "RWTableViewController.h"
#import "RWBasicTableViewCell.h"
#import "UIAlertView+RWBlock.h"

@interface RWTableViewController ()

/** @brief An array of NSString objects, data source of the table view. */
@property (strong, nonatomic) NSMutableArray *objects;

@end

@implementation RWTableViewController

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
  [self.tableView addGestureRecognizer:longPress];
  
  [super viewDidLoad];
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kIdentifier = @"Cell Identifier";
  
  RWBasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
  
  // Update cell content from data source.
  NSString *object = self.objects[indexPath.row];
  cell.titleLabel.text = object;
  
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.objects removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - IBActions

- (IBAction)addButtonPressed:(id)sender {
  
  // Display an alert view with a text input.
  UIAlertView *inputAlertView = [[UIAlertView alloc] initWithTitle:@"Add a new to-do item:" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Add", nil];
  
  inputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
  
  __weak RWTableViewController *weakself = self;
  
  // Add a completion block (using our category to UIAlertView).
  [inputAlertView setCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    
    // If user pressed 'Add'...
    if (buttonIndex == 1) {
      
      UITextField *textField = [alertView textFieldAtIndex:0];
      NSString *string = [textField.text capitalizedString];
      [weakself.objects addObject:string];
      
      NSUInteger row = [weakself.objects count] - 1;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
      [weakself.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
  }];
  
  [inputAlertView show];
}

- (IBAction)longPressGestureRecognized:(id)sender {
  
  UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
  UIGestureRecognizerState state = longPress.state;
  
  CGPoint location = [longPress locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
  
  static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
  static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
  
  switch (state) {
    case UIGestureRecognizerStateBegan: {
      if (indexPath) {
        sourceIndexPath = indexPath;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        // Take a snapshot of the selected row using helper method.
        snapshot = [self customSnapshoFromView:cell];
        
        // Add the snapshot as subview, centered at cell's center...
        __block CGPoint center = cell.center;
        snapshot.center = center;
        snapshot.alpha = 0.0;
        [self.tableView addSubview:snapshot];
        [UIView animateWithDuration:0.25 animations:^{
          
          // Offset for gesture location.
          center.y = location.y;
          snapshot.center = center;
          snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
          snapshot.alpha = 0.98;
          cell.alpha = 0.0;
          
        } completion:^(BOOL finished) {
          
          cell.hidden = YES;
          
        }];
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
        [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
        
        // ... and update source so it is in sync with UI changes.
        sourceIndexPath = indexPath;
      }
      break;
    }
      
    default: {
      // Clean up.
      UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
      cell.hidden = NO;
      cell.alpha = 0.0;
      
      [UIView animateWithDuration:0.25 animations:^{
        
        snapshot.center = cell.center;
        snapshot.transform = CGAffineTransformIdentity;
        snapshot.alpha = 0.0;
        cell.alpha = 1.0;
        
      } completion:^(BOOL finished) {
        
        sourceIndexPath = nil;
        [snapshot removeFromSuperview];
        snapshot = nil;
        
      }];
      
      break;
    }
  }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
  
  UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
  snapshot.layer.masksToBounds = NO;
  snapshot.layer.cornerRadius = 0.0;
  snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
  snapshot.layer.shadowRadius = 5.0;
  snapshot.layer.shadowOpacity = 0.4;
  
  return snapshot;
}

@end
