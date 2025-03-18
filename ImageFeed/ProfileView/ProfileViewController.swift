import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfile(profile: ProfileService.Profile)
    func updateProfileImage(profileImage: ProfileImageService.ProfileImage)
    func navigateToLoginScreen()
    func presentAlert(_ alert: UIAlertController)
    func updateUIAfterDataLoad()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Properties
    
    let token = OAuth2TokenStorage().token
    private var gradientForAvatar: CAGradientLayer?
    private var gradientForNameLabel: CAGradientLayer?
    private var gradientForLoginNameLabel: CAGradientLayer?
    private var gradientForDescriptionLabel: CAGradientLayer?
    var presenter: ProfilePresenterProtocol?
    
    private var isDataLoaded = false

    // MARK: - Lifecycle Methods
    override func viewDidLayoutSubviews() {
        animateGradients()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlackIOS
        setupConstraints()
        presenter?.observeProfileImageChanges()
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        addGradients()
        presenter = ProfilePresenter(
            view: self,
            profileService: ProfileService.shared,
            profileImageService: ProfileImageService.shared,
            tokenStorage: OAuth2TokenStorage.shared
        )
        presenter?.fetchProfileData()
    }
    
    deinit {
        presenter?.removeObserver()
        removeGradients()
    }
    
    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
        presenter?.showLogoutAlert()
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
    
    func updateProfile (profile: ProfileService.Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func updateProfileImage(profileImage: ProfileImageService.ProfileImage) {
        guard let imageUrlString = profileImage.profileImage.medium,
              let imageUrl = URL(string: imageUrlString) else {
            return
        }
        avatarImageView.kf.setImage(with: imageUrl)
    }
    
    func navigateToLoginScreen() {
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
    
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
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
        gradientForNameLabel?.cornerRadius = 12
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
    }
    
    private func animateGradients() {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 2.0
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
    }
    
    // MARK: - Update UI After Data Load
    
    func updateUIAfterDataLoad() {
        if !isDataLoaded {
            logoutButton.isHidden = false
        }
        removeGradients()
    }
    
    // MARK: - UI Elements
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "UserPic"))
        imageView.frame = CGRect(x: 100, y: 100, width: 70, height: 70)
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        
        return imageView
    } ()
    
    let nameLabel: UILabel = {
        let label = UILabel ()
        label.text = "Name Surname"
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Bold", size: 23)
        return label
    } ()
    
    let loginNameLabel: UILabel = {
        let label = UILabel ()
        label.text = "@yourloginname"
        label.textColor = .ypGray
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    } ()
    
    let descriptionLabel: UILabel = {
        let label = UILabel ()
        label.text = "Your description"
        label.textColor = .white
        label.font = UIFont(name: "SFProText-Regular", size: 13)
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton ()
        let imageButton = UIImage(named: "Exit")
        button.setImage(imageButton, for: .normal)
        button.isHidden = true
        return button
    } ()
}
