//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 12.11.2024.
//

import UIKit
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var imageURL: URL?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true

        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadImage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let image = imageView.image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func loadImage() {
        guard let imageURL else { return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let result):
                self.rescaleAndCenterImageInScrollView(image: result.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard let scrollView = scrollView, let imageView = imageView else { return }
        
        scrollView.layoutIfNeeded()
        
        print("scrollView.bounds.size:", scrollView.bounds.size)
        print("image.size:", image.size)
        
        let imageSize = image.size
        let scrollViewSize = scrollView.bounds.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let scale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = scale
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = scale
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        imageView.frame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
        scrollView.contentSize = imageView.frame.size
        
        centerImageInScrollView()
    }
    
    private func centerImageInScrollView() {
        guard let scrollView = scrollView, let imageView = imageView else { return }
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = imageView.frame.size
        
        let offsetX = max((scrollViewSize.width - imageSize.width) * 0.5, 0)
        let offsetY = max((scrollViewSize.height - imageSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    private func showError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Что-то пошло не так. Попробовать ещё раз?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                self?.loadImage()
            })
            self.present(alert, animated: true)
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
