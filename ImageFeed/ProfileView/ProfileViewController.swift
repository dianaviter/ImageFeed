//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Diana Viter on 11.11.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupConstraints()
    }
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        // код для нажатия кнопки logout
    }
    
    private func setupConstraints () {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private let avatarImageView: UIImageView = {
        let image = UIImage(named: "UserPic")
        let imageView = UIImageView(image: image)
        return imageView
    } ()
    
    private let nameLabel: UILabel = {
        let label = UILabel ()
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Bold", size: 23)
        return label
    } ()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel ()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    } ()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel ()
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton ()
        let imageButton = UIImage(named: "Exit")
        button.setImage(imageButton, for: .normal)
        return button
    } ()
}
