//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Рустам Ханахмедов on 30.08.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    private enum Credentials {
        static let login = "bateg@mail.ru"
        static let password = "5636245Pibuda"
        static let name = "Rustam Khanakhmedov"
        static let loginName = "@slepoi_kot"
    }
    
    private enum Constants {
        enum AccessibilityIdentifiers {
            static let loginButton = "Authenticate"
            static let webView = "UnsplashWebView"
            static let likeButton = "likeButton"
            static let singleBackButton = "nav back button white"
            static let logoutButton = "logoutButton"
        }
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["TestMode"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // После каждого теста убедимся что мы разлогинены
        logoutIfNeeded()
        super.tearDown()
    }
    
    func testAuth() throws {
        // Убедимся что мы разлогинены перед началом
        logoutIfNeeded()
        
        let authButton = app.buttons[Constants.AccessibilityIdentifiers.loginButton]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10), "Кнопка авторизации не найдена")
        authButton.tap()

        let webView = app.webViews[Constants.AccessibilityIdentifiers.webView]
        XCTAssertTrue(webView.waitForExistence(timeout: 15), "WebView не загрузился")
        
        // Ждем загрузки формы авторизации
        sleep(5) // Увеличиваем время ожидания
        
        // Находим поле логина и вводим данные
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено") // Увеличиваем таймаут
        
        loginTextField.tap()
        loginTextField.clearText()
        loginTextField.typeText(Credentials.login)
        
        // Скрываем клавиатуру после ввода логина
        if app.toolbars.buttons["Done"].waitForExistence(timeout: 3) {
            app.toolbars.buttons["Done"].tap()
        }
        sleep(1)
        
        // Находим поле пароля и вводим данные через буфер обмена
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поле пароля не найдено") // Увеличиваем таймаут
        
        passwordTextField.tap()
        
        // Используем буфер обмена для ввода пароля
        UIPasteboard.general.string = Credentials.password
        
        // Сначала пробуем выделить и вставить
        passwordTextField.doubleTap()
        sleep(1)
        
        // Вставляем из буфера обмена
        if app.menuItems["Paste"].waitForExistence(timeout: 3) {
            app.menuItems["Paste"].tap()
        } else {
            // Альтернатива: имитируем долгое нажатие для показа меню
            passwordTextField.press(forDuration: 1.5)
            if app.menuItems["Paste"].waitForExistence(timeout: 3) {
                app.menuItems["Paste"].tap()
            } else {
                // Fallback: обычный ввод
                passwordTextField.typeText(Credentials.password)
            }
        }
        
        // Скрываем клавиатуру после ввода пароля
        if app.toolbars.buttons["Done"].waitForExistence(timeout: 3) {
            app.toolbars.buttons["Done"].tap()
        } else if app.keyboards.buttons["Done"].waitForExistence(timeout: 2) {
            app.keyboards.buttons["Done"].tap()
        }
        sleep(1)
        
        // Нажимаем кнопку авторизации
        let loginButton = webView.buttons["Login"]
        if loginButton.waitForExistence(timeout: 5) {
            loginButton.tap()
        } else {
            // Альтернативный поиск кнопки
            webView.buttons.allElementsBoundByIndex.first?.tap()
        }
        
        // Ждем завершения авторизации и перехода на ленту
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 25), "Не удалось загрузить ленту после авторизации")
    }
    
    func testFeed() throws {
        // Убедимся что мы авторизованы
        ensureAuthentication()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
        
        cell.swipeUp()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 10))
        
        let likeButton = cellToLike.buttons[Constants.AccessibilityIdentifiers.likeButton]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        likeButton.tap()
        sleep(2)
        
        likeButton.tap()
        sleep(2)
        
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)
        
        let backButton = app.buttons[Constants.AccessibilityIdentifiers.singleBackButton]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        sleep(2)
    }
    
    func testProfile() throws {
        // Убедимся что мы авторизованы
        ensureAuthentication()
        sleep(2)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(2)
        
        XCTAssertTrue(app.staticTexts[Credentials.name].exists)
        XCTAssertTrue(app.staticTexts[Credentials.loginName].exists)
        
        // Здесь мы специально разлогиниваемся - это нормально для этого теста
        app.buttons[Constants.AccessibilityIdentifiers.logoutButton].tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.scrollViews.otherElements.buttons["Да"].tap()
        sleep(2)
        
        XCTAssertTrue(app.buttons[Constants.AccessibilityIdentifiers.loginButton].waitForExistence(timeout: 10))
    }
}

// MARK: - Helper Methods
extension ImageFeedUITests {
    
    private func logoutIfNeeded() {
        // Если уже на экране авторизации - ничего не делаем
        if app.buttons[Constants.AccessibilityIdentifiers.loginButton].exists {
            return
        }
        
        // Если авторизованы - выходим
        if app.tabBars.buttons.count > 1 {
            let profileTab = app.tabBars.buttons.element(boundBy: 1)
            if profileTab.waitForExistence(timeout: 5) {
                profileTab.tap()
                sleep(2)
                
                let logoutButton = app.buttons[Constants.AccessibilityIdentifiers.logoutButton]
                if logoutButton.waitForExistence(timeout: 5) {
                    logoutButton.tap()
                    
                    let alert = app.alerts["Пока, пока!"]
                    if alert.waitForExistence(timeout: 5) {
                        alert.scrollViews.otherElements.buttons["Да"].tap()
                        sleep(2)
                    }
                }
            }
        }
    }
    
    private func ensureAuthentication() {
        // Если уже авторизованы - ничего не делаем
        if !app.buttons[Constants.AccessibilityIdentifiers.loginButton].exists {
            return
        }
        
        // Если не авторизованы - запускаем процесс авторизации
        let authButton = app.buttons[Constants.AccessibilityIdentifiers.loginButton]
        authButton.tap()
        
        // Ждем либо WebView, либо сразу ленту
        let webView = app.webViews[Constants.AccessibilityIdentifiers.webView]
        if webView.waitForExistence(timeout: 10) {
            sleep(5) // Ждем автоматической авторизации
        }
        
        // Ждем ленту
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        _ = cell.waitForExistence(timeout: 20)
    }
}
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String, !stringValue.isEmpty else {
            return
        }
        
        // Двойной тап для выделения всего текста
        self.doubleTap()
        sleep(1)
        
        // Удаляем выделенный текст
        self.typeText(XCUIKeyboardKey.delete.rawValue)
        sleep(1)
    }
}
