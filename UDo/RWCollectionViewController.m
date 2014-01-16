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

@end
