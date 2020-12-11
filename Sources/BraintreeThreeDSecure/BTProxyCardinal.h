NS_ASSUME_NONNULL_BEGIN

// TODO: - add comment explaining this file

typedef NS_ENUM(NSUInteger, BTProxyCardinalSessionEnvironment) {
    BTProxyCardinalSessionEnvironmentStaging,
    BTProxyCardinalSessionEnvironmentProduction
};

typedef NS_ENUM(NSUInteger, BTProxyCardinalResponseActionCode) {
    BTProxyCardinalResponseActionCodeSuccess,
    BTProxyCardinalResponseActionCodeNoAction,
    BTProxyCardinalResponseActionCodeFailure,
    BTProxyCardinalResponseActionCodeError,
    BTProxyCardinalResponseActionCodeCancel,
    BTProxyCardinalResponseActionCodeTimeout
};

@protocol BTProxyCardinalResponse <NSObject>
@property (nonatomic, readonly) BTProxyCardinalResponseActionCode actionCode;
@property (nonatomic, readonly) NSInteger errorNumber;
@property (nonatomic, readonly) NSString *errorDescription;
@end

@protocol BTProxyCardinalSessionConfiguration <NSObject>
@property (nonatomic, assign) BTProxyCardinalSessionEnvironment deploymentEnvironment;
@end

typedef void (^BTProxyCardinalSessionSetupDidCompleteHandler)(NSString *consumerSessionId);
typedef void (^BTProxyCardinalSessionSetupDidValidateHandler)(id<BTProxyCardinalResponse> validateResponse);

@protocol BTProxyCardinalSession <NSObject>
- (void)configure:(id<BTProxyCardinalSessionConfiguration>)sessionConfig;
- (void)setupWithJWT:(NSString*)jwtString
         didComplete:(BTProxyCardinalSessionSetupDidCompleteHandler)didCompleteHandler
         didValidate:(BTProxyCardinalSessionSetupDidValidateHandler)didValidateHandler;
- (void)continueWithTransactionId:(nonnull NSString *)transactionId
                          payload:(nonnull NSString *)payload
              didValidateDelegate:(nonnull id)validationDelegate;
@end

@protocol BTProxyCardinalValidationDelegate
- (void)cardinalSession:(id<BTProxyCardinalSession>)session
stepUpDidValidateWithResponse:(id<BTProxyCardinalResponse> _Nullable) validateResponse
              serverJWT:(NSString *)serverJWT;
@end

NS_ASSUME_NONNULL_END
