//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Рустам Ханахмедов on 29.08.2025.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsPresenterDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsPresenterOnLogoutTap() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        
        // when
        viewController.presenter?.didTapLogoutButton()
        
        // then
        XCTAssertTrue(presenter.didTapLogoutButtonCalled)
    }
    
    func testPresenterFormatsDisplayNameCorrectly() {
        // given
        let presenter = ProfilePresenter()
        
        // when & then
        XCTAssertEqual(presenter.getDisplayName(""), "Имя Фамилия")
        XCTAssertEqual(presenter.getDisplayName("Test User"), "Test User")
    }
    
    func testPresenterFormatsDisplayBioCorrectly() {
        // given
        let presenter = ProfilePresenter()
        
        // when & then
        XCTAssertEqual(presenter.getDisplayBio(nil), "Нет описания")
        XCTAssertEqual(presenter.getDisplayBio("Test bio"), "Test bio")
    }
    
    func testPresenterUpdatesProfileWithFormattedData() {
        // given
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        let testProfile = Profile(
            username: "testuser",
            name: "", // Пустое имя
            loginName: "@testuser",
            bio: nil // Nil bio
        )
        
        // when - симулируем вызов loadProfileData
        let displayName = presenter.getDisplayName(testProfile.name)
        let displayBio = presenter.getDisplayBio(testProfile.bio)
        
        view.updateProfileDetails(
            name: displayName,
            loginName: testProfile.loginName,
            bio: displayBio
        )
        
        // then - проверяем что View получил отформатированные данные
        XCTAssertEqual(view.lastProfileName, "Имя Фамилия")
        XCTAssertEqual(view.lastProfileBio, "Нет описания")
        XCTAssertEqual(view.lastProfileLoginName, "@testuser")
    }
    
    func testPresenterSetsDefaultValues() {
        // given
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        
        // when
        view.setDefaultProfileValues()
        
        // then
        XCTAssertTrue(view.setDefaultProfileValuesCalled)
    }
    
    // Дополнительный тест для проверки обработки nil значений в модели
    func testProfileHandlesNilValues() {
        // given
        let profileResultWithNil = ProfileResult(
            username: "testuser",
            firstName: nil,
            lastName: nil,
            bio: nil
        )
        
        // when
        let profile = Profile(from: profileResultWithNil)
        
        // then
        XCTAssertEqual(profile.username, "testuser")
        XCTAssertEqual(profile.name, "") // Проверяем обработку nil имени
        XCTAssertEqual(profile.loginName, "@testuser")
        XCTAssertNil(profile.bio)
    }
}
