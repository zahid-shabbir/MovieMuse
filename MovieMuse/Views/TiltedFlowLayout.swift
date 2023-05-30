//
//  TiltedFlowLayout.swift
//  MovieMuse
//
//  Created by Zahid Shabbir on 21/05/2023.
//

import Foundation
import UIKit

// Custom UICollectionViewFlowLayout subclass.
class TiltedFlowLayout: UICollectionViewFlowLayout {
    let zoomFactor: CGFloat = 0.5
    let minimumLineSpacingValue: CGFloat = 8
    var itemSizeRatio: CGFloat

    var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }

    init(itemSizeRatio: CGFloat = 0.8) {
        self.itemSizeRatio = itemSizeRatio
        super.init()
        scrollDirection = .horizontal
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        // Calculate the item size based on the orientation of the device
        if isLandscape {
            itemSize = CGSize(width: collectionView.bounds.width * itemSizeRatio / 2, height: collectionView.bounds.height * itemSizeRatio)
        } else {
            itemSize = CGSize(width: collectionView.bounds.width * itemSizeRatio, height: collectionView.bounds.height * itemSizeRatio)
        }

        let verticalInsets = (collectionView.bounds.height - itemSize.height) / 2
        let horizontalInsets = (collectionView.bounds.width - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
    }

    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        for attribute in attributes {
            let collectionCenter = collectionView.frame.size.width / 2
            let offset = collectionView.contentOffset.x
            let normalizedCenter = attribute.center.x - offset
            let maxDistance = itemSize.width + minimumLineSpacing
            let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
            let ratio = (maxDistance - distance) / maxDistance

            let alpha = ratio * (1 - zoomFactor) + zoomFactor
            attribute.transform3D = CATransform3DMakeScale(alpha, alpha, 1)
            attribute.zIndex = Int(alpha * 10)

            let angle = (1 - ratio) * CGFloat(-Double.pi / 4)
            var transform = CATransform3DIdentity
            transform.m34 = -1 / 1000
            attribute.transform3D = CATransform3DRotate(transform, angle, 0, 1, 0)
        }

        return attributes
    }
}
