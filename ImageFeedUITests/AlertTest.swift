//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Diana Viter on 02.11.2024.
//

import XCTest
@testable import ImageFeed

class YourViewControllerTests: XCTestCase {

    func testShowAlert() {
        // Создайте экземпляр SplashViewController
        let viewController = SplashViewController()
        
        // Форсируйте загрузку представления
        viewController.loadViewIfNeeded()

        // Имитация ошибки
        viewController.fetchOAuthToken("Invalid data")
        
        // Время на выполнение асинхронной операции
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Проверьте, показывается ли алерт
            XCTAssertTrue(viewController.presentedViewController is UIAlertController)
            
            let alert = viewController.presentedViewController as! UIAlertController
            XCTAssertEqual(alert.title, "Ошибка")
            XCTAssertEqual(alert.message, "Не удалось получить токен")
            XCTAssert(alert.actions.contains { $0.title == "OK" })
        }
    }
}
