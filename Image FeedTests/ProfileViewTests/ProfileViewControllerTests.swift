//
//  Untitled.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

import XCTest
@testable import ImageFeed

class ProfileViewControllerTests: XCTestCase {
    
    var viewController: ProfileViewController!
    var mockPresenter: MockProfilePresenter!
    var mockTokenStorage: MockOAuth2TokenStorage!
    var presenter: ProfilePresenter!
    var mockView: MockProfileView!
    
    override func setUp() {
        super.setUp()
        viewController = ProfileViewController()
        mockPresenter = MockProfilePresenter()
        viewController.presenter = mockPresenter
        mockView = MockProfileView()
        presenter = ProfilePresenter(
                    view: mockView,
                    profileService: MockProfileService(),
                    profileImageService: MockProfileImageService(),
                    tokenStorage: MockOAuth2TokenStorage()
        )
    }
    
    override func tearDown() {
        viewController = nil
        mockPresenter = nil
        presenter = nil
        mockView = nil
        super.tearDown()
    }
    
    func testUpdateProfile() {
        let profile = ProfileService.Profile(
            username: "test_username",
            firstName: "Test",
            lastName: "User",
            bio: "Test bio"
        )
        
        viewController.updateProfile(profile: profile)
        
        XCTAssertEqual(viewController.nameLabel.text, "Test User")
        XCTAssertEqual(viewController.loginNameLabel.text, "@test_username")
        XCTAssertEqual(viewController.descriptionLabel.text, "Test bio")
    }
    
    func testUpdateProfileImage() {
        let expectation = XCTestExpectation(description: "Waiting for image loading")

        let profileImage = ProfileImageService.ProfileImage(
            profileImage: ProfileImageService.ProfileImageSizes(
                small: "https://images.unsplash.com/profile-1736113049262-c4d1a21a5e57image?ixlib=rb-4.0.3&crop=faces&fit=crop&w=32&h=32",
                medium: "https://images.unsplash.com/profile-1736113049262-c4d1a21a5e57image?ixlib=rb-4.0.3&crop=faces&fit=crop&w=64&h=64",
                large: "https://images.unsplash.com/profile-1736113049262-c4d1a21a5e57image?ixlib=rb-4.0.3&crop=faces&fit=crop&w=128&h=128"
            )
        )

        viewController.updateProfileImage(profileImage: profileImage)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertNotNil(self.viewController.avatarImageView.image)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testNavigateToLoginScreen() {
        print("✅ Создаем ожидание")
        let expectation = XCTestExpectation(description: "Ожидаем вызова navigateToLoginScreen")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("✅ Эмулируем вызов navigateToLoginScreen в Presenter")
            self.presenter.navigateToLoginScreen()

            print("🚀 Проверяем, был ли вызван navigateToLoginScreen в Presenter")
            XCTAssertTrue(self.mockView.didNavigateToLogin, "❌ Метод navigateToLoginScreen не был вызван в ViewController")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
