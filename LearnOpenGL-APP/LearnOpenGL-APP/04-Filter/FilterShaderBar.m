//
//  FilterShaderBar.m
//  LearnOpenGL-APP
//
//  Created by tutu on 2019/5/24.
//  Copyright © 2019 KK. All rights reserved.
//

#import "FilterShaderBar.h"

#define kFilterShaderBarCell @"FilterShaderBarCell"

@interface FilterShaderBar()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/**
 collectionView
 */
@property (nonatomic, strong) UICollectionView *collectionView;


/**
 当前的选择
 */
@property (nonatomic, assign) NSInteger index;

@end



@implementation FilterShaderBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    CGFloat itemW = 60;
    CGFloat itemH = CGRectGetHeight(self.frame);
    flowLayout.itemSize = CGSizeMake(itemW + 20, itemH);
    
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, -10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[FilterShaderBarCell class] forCellWithReuseIdentifier:kFilterShaderBarCell];
    [self addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterShaderBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFilterShaderBarCell forIndexPath:indexPath];
    cell.text = self.models[indexPath.row];
    cell.isSelected = indexPath.row == _index;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _index = indexPath.row;
    [self.collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterShaderBar:selected:)]) {
        [self.delegate filterShaderBar:self selected:_index];
    }
}

- (void)setModels:(NSArray<NSString *> *)models {
    _models = [models copy];
    [self.collectionView reloadData];
}

@end


@interface FilterShaderBarCell()


@property (nonatomic, strong) UILabel *title;

@end

@implementation FilterShaderBarCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 60)];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.font = [UIFont boldSystemFontOfSize:16];
    self.title.layer.masksToBounds = YES;
    self.title.layer.cornerRadius = 15;
    self.title.textColor = [UIColor whiteColor];
    [self addSubview:self.title];
}


- (void)setText:(NSString *)text {
    _text = text;
    self.title.text = text;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.title.backgroundColor = isSelected ? [UIColor colorWithRed:46/255.0 green:47/255.0 blue:67/255.0 alpha:1] : [UIColor clearColor];
}

@end
