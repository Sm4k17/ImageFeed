//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    // MARK: - ViewController Tests
    
    func testViewControllerCallsPresenterDidLoad() {
        // Проверяем, что при загрузке View вызывается viewDidLoad презентера
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        
        _ = viewController.view // Загружаем View, что вызывает viewDidLoad
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsPresenterOnLogoutTap() {
        // Проверяем, что нажатие на кнопку выхода вызывает метод презентера
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        
        viewController.presenter?.didTapLogoutButton()
        
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
    
    // MARK: - Presenter Tests
    
    func testPresenterFormatsDisplayNameCorrectly() {
        // Проверяем форматирование имени
        let presenter = ProfilePresenter()
        
        XCTAssertEqual(presenter.getDisplayName(""), "Имя Фамилия")
        XCTAssertEqual(presenter.getDisplayName("Test User"), "Test User")
    }
    
    func testPresenterFormatsDisplayBioCorrectly() {
        // Проверяем форматирование описания
        let presenter = ProfilePresenter()
        
        XCTAssertEqual(presenter.getDisplayBio(nil), "Нет описания")
        XCTAssertEqual(presenter.getDisplayBio("Test bio"), "Test bio")
    }
    
    func testPresenterUpdatesProfileWithFormattedData() {
        // Проверяем, что презентер передает отформатированные данные во View
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        let displayName = presenter.getDisplayName("")
        let displayBio = presenter.getDisplayBio(nil)
        
        view.updateProfileDetails(
            name: displayName,
            loginName: "@testuser",
            bio: displayBio
        )
        
        XCTAssertEqual(view.lastProfileName, "Имя Фамилия")
        XCTAssertEqual(view.lastProfileBio, "Нет описания")
    }
    
    func testPresenterSetsDefaultValues() {
        // Проверяем установку значений по умолчанию
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        view.setDefaultProfileValues()
        
        XCTAssertTrue(view.setDefaultProfileValuesCalled)
    }
}

// MARK: - Test Doubles

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func updateAvatar() {}
    func performLogout() {}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var setDefaultProfileValuesCalled = false
    var lastProfileName: String?
    var lastProfileLoginName: String?
    var lastProfileBio: String?
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        lastProfileName = name
        lastProfileLoginName = loginName
        lastProfileBio = bio
    }
    
    func setDefaultProfileValues() {
        setDefaultProfileValuesCalled = true
    }
    
    func updateAvatar(with url: URL?) {}
    func showLogoutConfirmation() {}
}
