#import "BTCollectionViewFlowLayoutWithSeparators.h"

NSString *BTCollectionViewFlowLayoutWithSeparatorsSeparatorKind = @"BTCollectionViewFlowLayoutWithSeparatorsSeparatorKind";

@interface TempSeparatorLine : UICollectionViewCell

@end

@implementation TempSeparatorLine

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height/2.0f/2.0f, frame.size.width, frame.size.height/2.0f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
    }
    return self;
}

@end

@interface BTCollectionViewFlowLayoutWithSeparators ()
@property (nonatomic, strong) NSMutableArray *itemAttributes;
@end

@implementation BTCollectionViewFlowLayoutWithSeparators

- (id)init {
    self = [super init];
    if (self) {
        [self registerClass:[TempSeparatorLine class] forDecorationViewOfKind:BTCollectionViewFlowLayoutWithSeparatorsSeparatorKind];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    NSParameterAssert(self.collectionView.numberOfSections == 1);
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    CGFloat totalWidth = self.collectionView.frame.size.width;
    self.itemSize = CGSizeMake(totalWidth/numberOfItems, self.collectionView.frame.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    for (UICollectionViewLayoutAttributes *attributes in [layoutAttributes subarrayWithRange:NSMakeRange(0, [layoutAttributes count] - 1)]) {
        UICollectionViewLayoutAttributes *separatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:BTCollectionViewFlowLayoutWithSeparatorsSeparatorKind withIndexPath:attributes.indexPath];
        separatorAttributes.frame = CGRectMake(attributes.frame.origin.x + attributes.frame.size.width, attributes.frame.origin.y, 1/2.0f, attributes.frame.size.height);
        [layoutAttributes addObject:separatorAttributes];
    }

    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(__unused NSString *)decorationViewKind atIndexPath:(__unused NSIndexPath *)indexPath {
    return [super layoutAttributesForDecorationViewOfKind:decorationViewKind atIndexPath:indexPath];
}

@end
