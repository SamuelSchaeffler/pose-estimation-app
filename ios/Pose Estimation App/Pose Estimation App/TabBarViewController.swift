//
//  TabBarViewController.swift
//  Pose Estimation App
//
//  Created by Samuel Schäffler on 23.09.23.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let vc1 = ImportedViewController()
        let vc2 = MiscViewController()
        
        vc1.title = "Importiert"
        vc2.title = "Sonstiges"
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always

        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        
        nav1.tabBarItem = UITabBarItem(title: "Importiert", image: UIImage(systemName: "photo.badge.checkmark")?.withRenderingMode(.alwaysOriginal), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Sonstiges", image: UIImage(systemName: "gear"), tag: 1)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true

        setViewControllers([nav1, nav2], animated: true)
        
    }
    
}
