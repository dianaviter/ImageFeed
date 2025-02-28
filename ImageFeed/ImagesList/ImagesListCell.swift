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
    
    var updateCellHeight: (() -> Void)?
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
    }
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let likeImage = photo.isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)
        
        cellImage.kf.indicatorType = .activity
        
        if let url = URL(string: photo.thumbImageURL) {
            cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Stub"),
                options: [
                    .transition(.fade(0.3))
                ],
                progressBlock: { receivedSize, totalSize in
                    print("Загрузка: \(receivedSize) из \(totalSize)")
                }
            ) { result in
                switch result {
                case .success(let value):
                    print("Загружено: \(value.source.url?.absoluteString ?? "")")
                    DispatchQueue.main.async {
                        self.updateCellHeight?()
                    }
                case .failure(let error):
                    print("Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        } else {
            cellImage.image = UIImage(named: "Stub")
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "Active") : UIImage(named: "NoActive")
        likeButton.setImage(likeImage, for: .normal)
    }
}
