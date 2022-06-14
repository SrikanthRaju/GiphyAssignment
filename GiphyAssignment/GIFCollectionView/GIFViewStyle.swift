//
//  GIFViewStyle.swift
//  GiphyAssignment
//
//  Created by Sri on 13/06/22.
//

import UIKit

enum GIFViewStyle: String, CaseIterable {
    case grid
    case list

    static let defaultSpacing: CGFloat = 10

    var displayName: String {
        return self.rawValue.capitalized
    }

    var layout: UICollectionViewLayout {
        switch self {
        case .list: return listLayout()
        case .grid: return gridLayout()
        }
    }


    private func listLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, layoutEnv in

            let isLandscape = UIDevice.current.orientation.isLandscape

            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(isLandscape ? 230 : 180))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = GIFViewStyle.defaultSpacing
            section.contentInsets = .init(top: GIFViewStyle.defaultSpacing,
                                          leading: GIFViewStyle.defaultSpacing,
                                          bottom: GIFViewStyle.defaultSpacing,
                                          trailing: GIFViewStyle.defaultSpacing)
            return section
        }
    }

    private func gridLayout() -> UICollectionViewLayout {
            return UICollectionViewCompositionalLayout { sectionIndex, layoutEnv in

                let isLandscape = UIDevice.current.orientation.isLandscape

                // Sizes
                let narrowSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
                let wideSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1))
                let rowSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(isLandscape ? 150 : 100))
                let sectionGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(isLandscape ? 650 : 400))

                // Items
                let narrowItem = NSCollectionLayoutItem(layoutSize: narrowSize)
                narrowItem.contentInsets = .init(top: GIFViewStyle.defaultSpacing/2,
                                                 leading: GIFViewStyle.defaultSpacing/2,
                                                 bottom: GIFViewStyle.defaultSpacing/2,
                                                 trailing: GIFViewStyle.defaultSpacing/2)
                let wideItem = NSCollectionLayoutItem(layoutSize: wideSize)
                wideItem.contentInsets = .init(top: GIFViewStyle.defaultSpacing/2,
                                               leading: GIFViewStyle.defaultSpacing/2,
                                               bottom: GIFViewStyle.defaultSpacing/2,
                                               trailing: GIFViewStyle.defaultSpacing/2)

                // Groups types
                let group111 = NSCollectionLayoutGroup.horizontal(layoutSize: rowSize, subitems: [narrowItem, narrowItem, narrowItem])
                let group21 = NSCollectionLayoutGroup.horizontal(layoutSize: rowSize, subitems: [wideItem, narrowItem])
                let group12 = NSCollectionLayoutGroup.horizontal(layoutSize: rowSize, subitems: [narrowItem, wideItem])

                // Section Group style
                let sectionGroup = NSCollectionLayoutGroup.vertical(layoutSize: sectionGroupSize, subitems: [group111, group21, group111, group12])

                let section = NSCollectionLayoutSection(group: sectionGroup)
                section.contentInsets = .init(top: GIFViewStyle.defaultSpacing/2,
                                              leading: GIFViewStyle.defaultSpacing/2,
                                              bottom: GIFViewStyle.defaultSpacing/2,
                                              trailing: GIFViewStyle.defaultSpacing/2)
                return section
            }
        }

}
