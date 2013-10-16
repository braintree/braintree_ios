# Sample Checkout Application
This is a sample application to demonstrate a bare bones iOS integration with Braintree and Venmo Touch.

### Running against the Braintree Sample Application
The sample checkout app will run out of the box against a Braintree demo application which is running on [Heroku](https://www.heroku.com/).  

Just open the braintree ios XCode project and click `Run`.

### Running against a local merchant server
To see a full stack sample integration (including server side code), we have provided a simple Sinatra application which you may run locally.

To run the sample merchant server, you'll need to input your credentials in two locatations:
`braintree-ios/venmo-touch/VenmoTouch.framework/Headers/VenmoTouchSettings.h`  
`braintree-ios/braintree/SampleCheckout/SampleMerchantServer/config.yml`  

In `braintree-ios/braintree/SampleCheckout/SCViewController.m`, 
set the value of `SAMPLE_CHECKOUT_BASE_URL`, to `http://localhost:4567`.

Then:  
`cd braintree-ios/braintree/SampleCheckout`  
`bundle`  
`bundle exec ruby app.rb`  
