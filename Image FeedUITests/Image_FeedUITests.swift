//
//  Image_FeedUITestsLaunchTests.swift
//  Image FeedUITests
//
//  Created by Diana Viter on 20.03.2025.
//

import XCTest

final class Image_FeedUITestsLaunchTests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append(contentsOf: ["testMode"])
        app.launch()
        print("✅ Тестовый режим запущен: \(ProcessInfo.processInfo.arguments)")
    }
    
    func testAuth() throws {
        if !app.buttons["Authenticate"].waitForExistence(timeout: 2) {
            print("⚠️ Автоматический вход обнаружен, делаем logout...")
            app.tabBars.buttons.element(boundBy: 1).tap()
            sleep(5)
            app.buttons["logout button"].tap()
            app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
            sleep(2)
        }
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка аутентификации не найдена")
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("diviterok@gmail.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("29061998")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        if app.buttons["Authenticate"].waitForExistence(timeout: 2) {
            let authButton = app.buttons["Authenticate"]
            XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка аутентификации не найдена")
            authButton.tap()
            
            let webView = app.webViews["UnsplashWebView"]
            XCTAssertTrue(webView.waitForExistence(timeout: 5))
            let loginTextField = webView.descendants(matching: .textField).element
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
            
            loginTextField.tap()
            loginTextField.typeText("diviterok@gmail.com")
            webView.swipeUp()
            
            let passwordTextField = webView.descendants(matching: .secureTextField).element
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
            
            passwordTextField.tap()
            passwordTextField.typeText("29061998")
            webView.swipeUp()
            
            webView.buttons["Login"].tap()
        }
        
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 5), "TableView did not appear in time")
        
        let tablesQuery = app.tables
        
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "TableView cell did not appear in time")
        
        firstCell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Cell for like button not found")
        
        cellToLike.buttons["like button"].tap()
        sleep(2)
        
        cellToLike.buttons["like button"].tap()
        sleep(2)
        
        cellToLike.tap()
    }
    
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(3)
        XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
