//
//  ThreeDS2Service.h
//  CardinalEMVCoSDK
//
//  Copyright © 2018 Cardinal Commerce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigParameters.h"
#import "UiCustomization.h"
#import "Warning.h"
#import "CardinalTransaction.h"


NS_ASSUME_NONNULL_BEGIN
/**
 * The ThreeDS2Service protocol is the main 3DS SDK protocol. It shall provide methods to process transactions.
 */
@protocol ThreeDS2Service

/**
 * The Merchant App should call the initialize method at the start of the payment stage of a transaction.
 * The app should pass configuration parameters, UI configuration parameters, and (optionally)
 * user locale to this method.
 * @param configParameters Configuration information that is used during initialization.
 * @param locale String that represents the locale for the app’s user interface.
                    For example, the value of locale can be “en_US” in Java.
 * @param uiCustomization UI configuration information that is used to specify the UI layout and theme. For example, font style and font size.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) initializeWithConfig: (nonnull ConfigParameters *) configParameters
                       locale: (nullable NSString *) locale
              uiCustomization: (nullable UiCustomization *) uiCustomization
                        error: (NSError **)error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(initialize(_:locale:uiCustomization:));


/**
 * The Merchant App should call the initialize method at the start of the payment stage of a transaction.
 * The app should pass configuration parameters, UI configuration parameters, and (optionally)
 * user locale to this method.
 * @param configParameters Configuration information that is used during initialization.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) initializeWithConfig: (nonnull ConfigParameters *) configParameters
                        error: (NSError **)error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(initialize(_:));


/**
 * The Merchant App should call the initialize method at the start of the payment stage of a transaction.
 * The app should pass configuration parameters, UI configuration parameters, and (optionally)
 * user locale to this method.
 * @param configParameters Configuration information that is used during initialization.
 * @param locale String that represents the locale for the app’s user interface.
 For example, the value of locale can be “en_US” in Java.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) initializeWithConfig: (nonnull ConfigParameters *) configParameters
                       locale: (nullable NSString *) locale
                        error: (NSError **)error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(initialize(_:locale:));


/**
 * The Merchant App should call the initialize method at the start of the payment stage of a transaction.
 * The app should pass configuration parameters, UI configuration parameters, and (optionally)
 * user locale to this method.
 * @param configParameters Configuration information that is used during initialization.
 * @param uiCustomization UI configuration information that is used to specify the UI layout and theme. For example, font style and font size.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) initializeWithConfig: (nonnull ConfigParameters *) configParameters
              uiCustomization: (nullable UiCustomization *) uiCustomization
                        error: (NSError **)error __attribute__((swift_error(nonnull_error)))
NS_SWIFT_NAME(initialize(_:uiCustomization:));


/**
 * The createTransaction method shall create an instance of the Transaction through which the
 * Merchant App shall get the data that is required to perform the transaction.
 * @param directoryServerId Registered Application Provider Identifier (RID) that is unique to the Payment System.
 * @param messageVersion Protocol version according to which the transaction shall be created.
 * @param error Reference to NSError Object to handle exceptions.
 * @return CETransaction
 */
- (CardinalTransaction *) createTransactionWithDirectoryServerId: (NSString *) directoryServerId
                                            messageVersion: (NSString *) messageVersion
                                                     error: (NSError **)error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME(createTransaction(_:messageVersion:));


/**
 * The createTransaction method creates an instance of the Transaction through which the
 * Merchant App will get the data that is required to perform the transaction.
 * @param directoryServerId Registered Application Provider Identifier (RID) that is unique to the Payment System.
 * @param error Reference to NSError Object to handle exceptions.
 * @return CETransaction Transaction for given Directory Server ID.
 */
- (CardinalTransaction *) createTransactionWithDirectoryServerId: (NSString *) directoryServerId
                                                     error: (NSError **)error __attribute__((swift_error(nonnull_error)))
NS_SWIFT_NAME(createTransaction(_:));


/**
 * The cleanup method frees up resources that are used by the 3DS SDK.
 * It shall be called only once during a single Merchant App session.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (BOOL) cleanup:(NSError **)error __attribute__((swift_error(nonnull_error)))
NS_SWIFT_NAME(cleanup());


/**
 * The getSDKVersion method returns the version of the 3DS SDK that is integrated with the Merchant App.
 * @param error Reference to NSError Object to handle exceptions.
 */
- (NSString *) getSDKVersion:(NSError **)error __attribute__((swift_error(nonnull_error)))
NS_SWIFT_NAME(getSDKVersion());


/**
 * The getWarnings method returns the warnings produced by the 3DS SDK during initialization.
 * @return List of Warnings
 */
- (NSArray<Warning *> *) getWarnings;


@end
NS_ASSUME_NONNULL_END
