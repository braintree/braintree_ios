/* Macros for shimming Xcode 7 nullability macros in Xcode 6 projects */
#if __has_feature(nullability)
#   define BT_ASSUME_NONNULL_BEGIN      NS_ASSUME_NONNULL_BEGIN
#   define BT_ASSUME_NONNULL_END        NS_ASSUME_NONNULL_END
#   define BT_NULLABLE                  nullable
#   define __BT_NULLABLE                __nullable
#else
#   define BT_ASSUME_NONNULL_BEGIN
#   define BT_ASSUME_NONNULL_END
#   define BT_NULLABLE
#   define __BT_NULLABLE
#endif

#if __has_feature(objc_generics)
#   define BT_GENERICS(class, ...)      class<__VA_ARGS__>
#   define BT_GENERICS_TYPE(type)       type
#else
#   define BT_GENERICS(class, ...)      class
#   define BT_GENERICS_TYPE(type)       id
#endif
