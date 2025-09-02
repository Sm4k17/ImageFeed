//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    // MARK: - Test Data
    private enum TestData {
        static let email = "bateg@mail.ru"
        static let password = "5636245Pibuda"
        static let userName = "Rustam Khanakhmedov"
        static let userLogin = "@slepoi_kot"
    }
    
    private enum Identifiers {
        static let loginButton = "Authenticate"
        static let webView = "UnsplashWebView"
        static let likeButton = "likeButton"
        static let backButton = "nav back button white"
        static let logoutButton = "logoutButton"
        static let profileName = "nameLabel"
        static let profileLogin = "loginNameLabel"
    }
    
    // MARK: - Setup and Teardown
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // После каждого теста выходим из аккаунта (только для тестов где это нужно)
        // В testAuth() не выходим, чтобы следующие тесты могли использовать авторизацию
    }
    
    // MARK: - Test Cases
    
    func testAuth() throws {
        // Нажать кнопку авторизации
        let authButton = app.buttons[Identifiers.loginButton]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10))
        authButton.tap()

        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews[Identifiers.webView]
        XCTAssertTrue(webView.waitForExistence(timeout: 15))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText(TestData.email)
        
        // Скрываем клавиатуру после ввода логина
        if app.toolbars.buttons["Done"].waitForExistence(timeout: 3) {
            app.toolbars.buttons["Done"].tap()
        }
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10))
        passwordTextField.tap()
        
        // Используем буфер обмена для ввода пароля
        UIPasteboard.general.string = TestData.password
        passwordTextField.doubleTap()
        
        if app.menuItems["Paste"].waitForExistence(timeout: 3) {
            app.menuItems["Paste"].tap()
        } else {
            // Fallback: обычный ввод
            passwordTextField.typeText(TestData.password)
        }
        
        // Скрыть клавиатуру после ввода пароля
        if app.toolbars.buttons["Done"].waitForExistence(timeout: 3) {
            app.toolbars.buttons["Done"].tap()
        } else if app.keyboards.buttons["Done"].waitForExistence(timeout: 2) {
            app.keyboards.buttons["Done"].tap()
        }
        
        // Нажать кнопку логина
        let loginButton = webView.buttons["Login"]
        if loginButton.waitForExistence(timeout: 5) {
            loginButton.tap()
        }
        
        // Подождать, пока открывается экран ленты
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 25))
        
        // НЕ выходим из аккаунта - остаемся авторизованными для следующих тестов
    }
    
    func testFeed() throws {
        // Убедиться что авторизованы (используем авторизацию из testAuth)
        let firstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        app.swipeUp()
        sleep(5)
        
        // Поставить лайк в ячейке верхней картинки
        let likeButton = firstCell.buttons[Identifiers.likeButton]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        sleep(5)
        
        // Отменить лайк в ячейке верхней картинки
        likeButton.tap()
        sleep(5)
        
        // Нажать на верхнюю ячейку
        firstCell.tap()
        sleep(2)
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        // Вернуться на экран ленты
        let backButton = app.buttons[Identifiers.backButton]
        if backButton.waitForExistence(timeout: 5) {
            backButton.tap()
        }
        sleep(2)
        
        // НЕ выходим из аккаунта - остаемся авторизованными для testProfile
    }
    
    func testProfile() throws {
        // Убедиться что авторизованы (используем авторизацию из предыдущих тестов)
        let firstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts[TestData.userName].exists)
        XCTAssertTrue(app.staticTexts[TestData.userLogin].exists)
        
        // Нажать кнопку логаута
        let logoutButton = app.buttons[Identifiers.logoutButton]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        // Подтвердить выход
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.scrollViews.otherElements.buttons["Да"].tap()
        sleep(2)
        
        // Проверить, что открылся экран авторизации
        XCTAssertTrue(app.buttons[Identifiers.loginButton].waitForExistence(timeout: 10))
    }
}
