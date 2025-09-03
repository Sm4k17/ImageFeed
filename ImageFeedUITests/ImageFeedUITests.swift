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
        static let email = ""
        static let password = ""
        static let userName = ""
        static let userLogin = ""
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
        // Пусто - состояние сохраняется между тестами
    }
    
    // MARK: - Helper Methods
    private func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 10) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    // MARK: - Test Cases
    func testAuth() throws {
        // Нажать кнопку авторизации
        let authButton = app.buttons[Identifiers.loginButton]
        waitForElementToAppear(authButton)
        authButton.tap()

        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews[Identifiers.webView]
        waitForElementToAppear(webView)
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        waitForElementToAppear(loginTextField)
        loginTextField.tap()
        loginTextField.typeText(TestData.email)
        
        // Скрываем клавиатуру после ввода логина
        if app.toolbars.buttons["Done"].waitForExistence(timeout: 3) {
            app.toolbars.buttons["Done"].tap()
        }
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        waitForElementToAppear(passwordTextField)
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
        waitForElementToAppear(loginButton)
        loginButton.tap()
        
        // Подождать, пока открывается экран ленты
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        waitForElementToAppear(cell)
        
        // НЕ выходим из аккаунта - остаемся авторизованными для следующих тестов
    }
    
    @MainActor
    func testFeed() throws {
        let tablesQuery = app.tables
        
        // Загружается экран ленты
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        waitForElementToAppear(cell)
        
        // Жест «смахивания» вверх по экрану
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        waitForElementToAppear(cellToLike)
        
        // Поставить лайк в ячейке верхней картинки
        let likeButton = cellToLike.buttons[Identifiers.likeButton]
        waitForElementToAppear(likeButton)
        likeButton.tap()
        
        // Ждем завершения запроса
        let progressHUD = app.activityIndicators.element
        if progressHUD.waitForExistence(timeout: 3) {
            XCTAssertFalse(progressHUD.waitForExistence(timeout: 15))
        }
        
        // Ждем немного, чтобы API "отдохнул"
        sleep(5)
        
        // Отменить лайк в ячейке верхней картинки
        // Переполучаем кнопку, так как она могла обновиться
        let updatedLikeButton = cellToLike.buttons[Identifiers.likeButton]
        waitForElementToAppear(updatedLikeButton)
        updatedLikeButton.tap()
        
        // Ждем завершения второго запроса
        if progressHUD.waitForExistence(timeout: 3) {
            XCTAssertFalse(progressHUD.waitForExistence(timeout: 15))
        }
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        
        sleep(2)
        
        // Подождать, пока картинка открывается на весь экран
        let image = app.scrollViews.images.element(boundBy: 0)
        waitForElementToAppear(image)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons[Identifiers.backButton]
        waitForElementToAppear(navBackButtonWhiteButton)
        navBackButtonWhiteButton.tap()
        
        // Проверить, что вернулись в ленту
        waitForElementToAppear(cell)
    }
    
    @MainActor
    func testProfile() throws {
        // Подождать, пока открывается и загружается экран ленты
        let firstCell = app.tables.children(matching: .cell).element(boundBy: 0)
        waitForElementToAppear(firstCell)
        
        // Перейти на экран профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        waitForElementToAppear(profileTab)
        profileTab.tap()
        
        // Проверка персональных данных
        let nameLabel = app.staticTexts[Identifiers.profileName]
        let loginLabel = app.staticTexts[Identifiers.profileLogin]
        
        waitForElementToAppear(nameLabel)
        waitForElementToAppear(loginLabel)
        
        XCTAssertEqual(nameLabel.label, TestData.userName)
        XCTAssertEqual(loginLabel.label, TestData.userLogin)
        
        // Нажать кнопку логаута
        let logoutButton = app.buttons[Identifiers.logoutButton]
        waitForElementToAppear(logoutButton)
        logoutButton.tap()
        
        // Подтвердить выход
        let alert = app.alerts["Пока, пока!"]
        waitForElementToAppear(alert)
        alert.scrollViews.otherElements.buttons["Да"].tap()
        
        // Проверить, что открылся экран авторизации
        let authButton = app.buttons[Identifiers.loginButton]
        waitForElementToAppear(authButton)
    }
}
