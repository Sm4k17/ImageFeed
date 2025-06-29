//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Рустам Ханахмедов on 21.06.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton() {
    }
}
