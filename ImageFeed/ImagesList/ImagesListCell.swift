//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Diana Viter on 05.11.2024.
//

import Foundation
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    weak var delegate: ImagesListCellDelegate?
    private var gradientForImage: CAGradientLayer?
    private var isDataLoaded = false
    var updateCellHeight: (() -> Void)?
    
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
        animateGradient()
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        removeGradient()
    }
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        if let createdAt = photo.createdAt {
            dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = "Unknown date"
            print("Error: createdAt is nil for photo with ID: \(photo.id)")
        }

        setIsLiked(photo.isLiked)
      
        cellImage.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            cellImage.kf.setImage(
                with: url,
                placeholder: nil,
                options: [.transition(.fade(0.3))],
                progressBlock: { receivedSize, totalSize in
                    print("Loading: \(receivedSize) from \(totalSize)")
                }
            ) { result in
                switch result {
                case .success(let value):
                    print("Loaded: \(value.source.url?.absoluteString ?? "")")
                    self.removeGradient()
                    self.isDataLoaded = true
                    DispatchQueue.main.async {
                        self.updateCellHeight?()
                    }
                case .failure(let error):
                    print("Loading error: \(error.localizedDescription)")
                }
            }
        } else {
            cellImage.image = UIImage(named: "Stub")
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = "like button"
    }
    
    // MARK: - Gradient Layers
    
    private func addGradient() {
        if isDataLoaded {
            return
        }
        gradientForImage = CAGradientLayer()
        gradientForImage?.frame = cellImage.bounds
        gradientForImage?.locations = [0, 0.1, 0.3]
        gradientForImage?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForImage?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForImage?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForImage?.cornerRadius = 2
        cellImage.layer.addSublayer(gradientForImage ?? CAGradientLayer())
    }
    
    private func animateGradient() {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
        gradientForImage?.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    private func removeGradient() {
        cellImage.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        gradientForImage = nil
    }
}

