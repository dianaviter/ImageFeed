import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    let token = OAuth2TokenStorage().token
    private var profileImageServiceObserver: NSObjectProtocol?
    private var gradientForAvatar: CAGradientLayer?
    private var gradientForNameLabel: CAGradientLayer?
    private var gradientForLoginNameLabel: CAGradientLayer?
    private var gradientForDescriptionLabel: CAGradientLayer?
    
    private var isDataLoaded = false

    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupConstraints()
        observeProfileImageChanges()
        fetchProfileData()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        addGradients()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        removeGradients()
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    // MARK: - Private Methods
    
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
    
    private func observeProfileImageChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let userInfo = notification.userInfo as? [String: ProfileImageService.ProfileImage],
                  let profileImage = userInfo["profileImage"] else {
                return
            }
            self.updateProfileImage(profileImage: profileImage)
        }
    }
    
    private func fetchProfileData () {
        guard let token = token else {
            print("Token is nil")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.updateProfile(profile: profile)
                self?.profileImageService.fetchProfileImage(token) { imageResult in
                    switch imageResult {
                    case .success(let profileImage):
                        self?.updateProfileImage(profileImage: profileImage)
                        self?.isDataLoaded = true
                        self?.updateUIAfterDataLoad()
                    case .failure (let error):
                        print ("Failed to fetch profile (Image): \(error)")
                    }
                }
            case .failure (let error):
                print ("Failed to fetch profile: \(error)")
            }
        }
    }
    
    private func updateProfile (profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func updateProfileImage(profileImage: ProfileImageService.ProfileImage) {
        guard let imageUrlString = profileImage.profileImage.medium,
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        avatarImageView.kf.setImage(with: imageUrl)
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.logout()
        }

        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)

        alert.addAction(yesAction)
        alert.addAction(noAction)

        present(alert, animated: true, completion: nil)
    }
    
    private func logout() {
        OAuth2Service.shared.logout()
        switchToLoginScreen()
    }
    
    private func switchToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authVC = storyboard.instantiateViewController(identifier: "AuthViewController") as? AuthViewController else {
            print("Failed to create AuthViewController")
            return
        }
        authVC.modalPresentationStyle = .fullScreen
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = authVC
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Gradient Layers
    
    private func addGradients() {
        if isDataLoaded {
            return
        }

        nameLabel.layoutIfNeeded()
        loginNameLabel.layoutIfNeeded()
        descriptionLabel.layoutIfNeeded()
        avatarImageView.layoutIfNeeded()
        
        gradientForAvatar = CAGradientLayer()
        gradientForAvatar?.frame = avatarImageView.bounds
        gradientForAvatar?.locations = [0, 0.1, 0.3]
        gradientForAvatar?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForAvatar?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForAvatar?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForAvatar?.cornerRadius = avatarImageView.bounds.width / 2
        avatarImageView.layer.addSublayer(gradientForAvatar ?? CAGradientLayer())
        
        gradientForNameLabel = CAGradientLayer()
        gradientForNameLabel?.frame = nameLabel.bounds
        gradientForNameLabel?.locations = [0, 0.1, 0.3]
        gradientForNameLabel?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForNameLabel?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForNameLabel?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForNameLabel?.cornerRadius = 8
        nameLabel.layer.addSublayer(gradientForNameLabel ?? CAGradientLayer())
        
        gradientForLoginNameLabel = CAGradientLayer()
        gradientForLoginNameLabel?.frame = loginNameLabel.bounds
        gradientForLoginNameLabel?.locations = [0, 0.1, 0.3]
        gradientForLoginNameLabel?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForLoginNameLabel?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForLoginNameLabel?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForLoginNameLabel?.cornerRadius = 8
        loginNameLabel.layer.addSublayer(gradientForLoginNameLabel ?? CAGradientLayer())
        
        gradientForDescriptionLabel = CAGradientLayer()
        gradientForDescriptionLabel?.frame = descriptionLabel.bounds
        gradientForDescriptionLabel?.locations = [0, 0.1, 0.3]
        gradientForDescriptionLabel?.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradientForDescriptionLabel?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForDescriptionLabel?.endPoint = CGPoint(x: 1, y: 0.5)
        gradientForDescriptionLabel?.cornerRadius = 8
        descriptionLabel.layer.addSublayer(gradientForDescriptionLabel ?? CAGradientLayer())
        
        animateGradients()
    }
    
    private func animateGradients() {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 3.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]

        gradientForAvatar?.add(gradientChangeAnimation, forKey: "locationsChange")
        gradientForNameLabel?.add(gradientChangeAnimation, forKey: "locationsChange")
        gradientForLoginNameLabel?.add(gradientChangeAnimation, forKey: "locationsChange")
        gradientForDescriptionLabel?.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    private func removeGradients() {
        gradientForAvatar?.removeFromSuperlayer()
        gradientForNameLabel?.removeFromSuperlayer()
        gradientForLoginNameLabel?.removeFromSuperlayer()
        gradientForDescriptionLabel?.removeFromSuperlayer()
        view.layoutIfNeeded()
    }
    
    // MARK: - Update UI After Data Load
    
    private func updateUIAfterDataLoad() {
        if isDataLoaded {
            logoutButton.isHidden = false
        }
        removeGradients()
    }
    
    // MARK: - UI Elements
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "UserPic"))
        imageView.frame = CGRect(x: 100, y: 100, width: 70, height: 70)
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        return imageView
    } ()
    
    private let nameLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Bold", size: 23)
        return label
    } ()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .ypGray
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    } ()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel ()
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton ()
        let imageButton = UIImage(named: "Exit")
        button.setImage(imageButton, for: .normal)
        button.isHidden = true // Скрываем кнопку до загрузки данных
        return button
    } ()
}
