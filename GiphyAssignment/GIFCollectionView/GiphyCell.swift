//
//  GiphyCell.swift
//  GiphyAssignment
//
//  Created by Sri on 12/06/22.
//

import Foundation
import UIKit.UICollectionViewCell
import Gifu


// MARK:- GIFCellDelegate
protocol GiphyCellDelegate: AnyObject {
    func didSelectFavourite(_ cell: GiphyCell, forIndexPath indexPath: IndexPath)
}

///
///The `GiphyCell` used to represent GIF data in the collection view.
///

final class GiphyCell: UICollectionViewCell, CellDataProvider {

    private let animatedImageView = GIFImageView()
    private let favoriteButton = UIButton(type: .custom)
    weak var delegate: GiphyCellDelegate?
    private var indexPath: IndexPath?

    typealias DataItem = GIF

    override init(frame: CGRect) {
        super.init(frame: frame)
        createUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(_ model: DataItem, forIndexPath indexPath: IndexPath) {
        self.indexPath = indexPath

        model.getGifPathUrl { [weak self] url in
            if let gifPathUrl = url {
                self?.animatedImageView.prepareForAnimation(withGIFURL: gifPathUrl)
            }
        }
        favoriteButton.isSelected = isFavouriteGIF(model.id)
    }

    func updateGIF(data: Data) {
        animatedImageView.animate(withGIFData: data)
    }
}

// MARK: - UI configuration & Layout

extension GiphyCell {

    private func createUI() {
        contentView.layer.cornerRadius = 9.0
        contentView.layer.borderWidth = 0.2
        contentView.layer.borderColor = UIColor.init(white: 0.6, alpha: 0.9).cgColor
        contentView.clipsToBounds = true
        addAnimatedImageView()
        addFavoriteButton()
        setupAnimatedImageViewConstraints()
        setupFavoriteButtonConstraints()
    }

    private func addAnimatedImageView() {
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        animatedImageView.backgroundColor = .gray
        animatedImageView.clipsToBounds = true
        animatedImageView.contentMode = .scaleAspectFill
        self.contentView.addSubview(animatedImageView)
    }

    private func setupAnimatedImageViewConstraints() {
        animatedImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        animatedImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        animatedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        animatedImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    private func addFavoriteButton() {

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        favoriteButton.contentMode = .center
        favoriteButton.setImage(UIImage.init(systemName: ImageAsserts.Icon.favUnselected.imageName), for: .normal)
        favoriteButton.setImage(UIImage.init(systemName: ImageAsserts.Icon.favSelected.imageName), for: .selected)
        favoriteButton.setImage(UIImage.init(systemName: ImageAsserts.Icon.favUnselected.imageName), for: .disabled)
        favoriteButton.tintColor = .red
        favoriteButton.backgroundColor = .init(white: 0.0, alpha: 0.4)
        favoriteButton.layer.cornerRadius = 18
        favoriteButton.clipsToBounds = true
        favoriteButton.addTarget(self, action: #selector(favouriteAction), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
    }

    private func setupFavoriteButtonConstraints() {
        favoriteButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        favoriteButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        animatedImageView.prepareForReuse()
        delegate = nil
    }

    func stopAnimatingGIF() {
        self.animatedImageView.stopAnimatingGIF()
    }

    func startAnimatingGIF() {
        self.animatedImageView.startAnimatingGIF()
    }

    @objc private func favouriteAction(_ sender: Any) {
        if let indexPath = indexPath {
            delegate?.didSelectFavourite(self, forIndexPath: indexPath)
        }
    }
}
