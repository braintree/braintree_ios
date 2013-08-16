# Braintree iOS Encryption

This library is for use with [Braintree's payment gateway](http://braintreepayments.com/) in concert with one of [the supported client libraries](http://braintreepayments.com/docs).  It encrypts sensitive payment information using the public key of an asymmetric key pair.

## Add `braintree_ios` to your Xcode Project

See the README steps at https://github.com/braintree/braintree_ios/ for instructions on how to add the `braintree_ios` SDK, which includes `BTEncryption`, to your Xcode project.

## Configuration

When Client-Side encryption is enabled for your Braintree Gateway account, a key pair is generated and you are given a specially formatted version of the public key.

Retrive your client side encryption key from either https://www.braintreegateway.com/ or https://sandbox.braintreegateway.com/

Configure the library to use your public key:

```objc
  BTEncryption * braintree = [[BTEncryption alloc]
      initWithPublicKey:@"YOUR_CLIENT_SIDE_PUBLIC_ENCRYPTION_KEY"];
```

And call the `encrypt` method passing in the data you wish to be encrypted.

```objc
NSString* encryptedValue = [braintree encryptString: @"sensitiveValue"];
```

Because we are using asymmetric encryption, you will be unable to decrypt the data you have encrypted using your public encryption key. Only the Braintree Gateway will be able to decrypt these encrypted values.  This means that `encryptedValue` is now safe to pass through your servers to be used in the Server-to-Server API of one of our client libraries.


## Encrypting Values from UITextFields

The normal use case for this library is to encrypt a credit card number and CVV code before data is submitted to your servers. A simple example of a UIViewController might look something like this:

```objc
//MainViewController.h
@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  UITableView * formTable;
  UITableViewCell * ccNumberCell;
  UITableViewCell * ccExpirationCell;
  UITextField * ccNumberField;
  UITextField * ccExpirationField;
  NSDictionary * cells;
}

extern NSString * const PUBLIC_KEY;

// outlets
@property(nonatomic, retain) IBOutlet UITableView * formTable;
@property(nonatomic, retain) IBOutlet UITableViewCell * ccNumberCell;
@property(nonatomic, retain) IBOutlet UITableViewCell * ccExpirationCell;
@property(nonatomic, retain) IBOutlet UITextField * ccNumberField;
@property(nonatomic, retain) IBOutlet UITextField * ccExpirationField;

// internal data
@property(nonatomic, retain) NSDictionary * cells;

// methods
-(IBAction) formSubmitted:(id) sender;
-(void) showAlertWithMessage:(NSString*) message;
-(NSDictionary*) getFormData;
-(NSDictionary*) encryptFormData:(NSDictionary*) formData;

@end
```

```objc
//MainViewController.m
#import "MainViewController.h"
#import "BTEncryption.h"
#import "HTTPClient.h"
#import "JSONKit.h"


@implementation MainViewController

NSString * const PUBLIC_KEY = @"your-client-side-encryption-key";

@synthesize formTable, ccNumberField, ccExpirationField, ccNumberCell, ccExpirationCell, cells;

- (IBAction) formSubmitted:(id) sender {
  HTTPClient * http = [[[HTTPClient alloc] init] autorelease];

  [http postPath: @"/" parameters: [self encryptFormData: [self getFormData]]
    success: ^(AFHTTPRequestOperation * operation, id responseObject) {
      NSDictionary * response = [[JSONDecoder decoder] objectWithData: responseObject];
      [self showAlertWithMessage: [NSString stringWithFormat: @"%@", response]];
    }
    failure: ^(AFHTTPRequestOperation * operation, NSError * error) {
      [self showAlertWithMessage: [NSString stringWithFormat: @"%@", error]];
  }];
}

-(void) showAlertWithMessage: (NSString*) message {
  [[[[  UIAlertView alloc]
      initWithTitle: @"Submitted!"
      message: message
      delegate: self
      cancelButtonTitle: @"Ok! Thanks!"
      otherButtonTitles: nil]
    autorelease]
  show];
}

-(NSDictionary*) encryptFormData:(NSDictionary*) formData {
  BTEncryption * braintree = [[[BTEncryption alloc] initWithPublicKey: PUBLIC_KEY] autorelease];
  NSMutableDictionary * encryptedParams = [[[NSMutableDictionary alloc] init] autorelease];

  [formData enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL * stop) {
    [encryptedParams setObject: [braintree encryptString: object] forKey: key];
  }];

  return encryptedParams;
}

-(NSDictionary*) getFormData {
  NSMutableDictionary * formData = [[[NSMutableDictionary alloc] init] autorelease];
  [formData setObject: ccNumberField.text     forKey: @"cc_number"];
  [formData setObject: ccExpirationField.text forKey: @"cc_exp_date"];
  return formData;
}

- (UITableViewCell*) tableView:(UITableView*) tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [[cells allValues] objectAtIndex: [indexPath row]];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void) viewDidUnload {
  [super viewDidUnload];
  [formTable release];
  [ccNumberField release];
  [ccNumberCell release];
  [ccExpirationField release];
  [ccExpirationCell release];
  [cells release];
}

- (NSInteger)  numberOfSectionsInTableView:(UITableView *)tableView { return 1; }
- (NSInteger)  tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return [cells count]; }
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { return nil; }
- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section { return nil; }

- (void) viewDidLoad {
  cells = [[NSDictionary alloc] initWithObjectsAndKeys:
           ccNumberCell, @"creditCardNumber",
           ccExpirationCell, @"creditCardExpiration", nil];
  [super viewDidLoad];
}

@end
```
