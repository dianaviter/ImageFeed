//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Diana Viter on 18.03.2025.
//

import Testing
@testable import ImageFeed
import XCTest

final class ProfilePresenterTests: XCTestCase {
    var presenter: ProfilePresenter!
    var mockView: MockProfileView!
    var mockProfileService: MockProfileService!
    var mockProfileImageService: MockProfileImageService!
    var mockTokenStorage: MockOAuth2TokenStorage!

    override func setUp() {
        super.setUp()
        mockView = MockProfileView()
        mockProfileService = MockProfileService()
        mockProfileImageService = MockProfileImageService()
        mockTokenStorage = MockOAuth2TokenStorage()
        mockTokenStorage.token = "test_token"

        presenter = ProfilePresenter(
            view: mockView,
            profileService: mockProfileService,
            profileImageService: mockProfileImageService, tokenStorage: mockTokenStorage
        )
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockProfileService = nil
        mockProfileImageService = nil
        mockTokenStorage = nil
        super.tearDown()
    }

    func testFetchProfileData_Success() {
        let expectation = XCTestExpectation(description: "Ожидание загрузки профиля")

        let expectedProfile = ProfileService.Profile(
            username: "test",
            firstName: "Test",
            lastName: "Test",
            bio: "Test bio"
        )
        mockProfileService.profile = expectedProfile

        presenter.fetchProfileData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(self.mockView.updatedProfile?.name, expectedProfile.name)
            XCTAssertEqual(self.mockView.updatedProfile?.loginName, expectedProfile.loginName)
            XCTAssertEqual(self.mockView.updatedProfile?.bio, expectedProfile.bio)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }


    func testFetchProfileData_Failure() {
        presenter.fetchProfileData()
        
        XCTAssertFalse(mockView.profileUpdated)
    }

    func testShowLogoutAlert() {
        presenter.showLogoutAlert()
        
        XCTAssertTrue(mockView.didPresentAlert)
    }

    func testNavigateToLoginScreen() {
        presenter.logout()
        
        XCTAssertTrue(mockView.didNavigateToLogin)
    }
}
