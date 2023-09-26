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
                
        let vc1 = PhotoPickerViewController()
        let vc2 = ImportedViewController()
        let vc3 = MiscViewController()
        
        
        
        //vc1.title = "Gallerie"
        vc2.title = "Importiert"
        vc3.title = "Sonstiges"
        
        vc1.navigationItem.largeTitleDisplayMode = .always
        vc2.navigationItem.largeTitleDisplayMode = .always
        vc3.navigationItem.largeTitleDisplayMode = .always

        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        
        nav1.tabBarItem = UITabBarItem(title: "Gallerie", image: UIImage(systemName: "photo.badge.plus")?.withRenderingMode(.alwaysOriginal), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Importiert", image: UIImage(systemName: "photo.badge.checkmark")?.withRenderingMode(.alwaysOriginal), tag: 1)
        nav3.tabBarItem = UITabBarItem(title: "Sonstiges", image: UIImage(systemName: "gear"), tag: 1)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        

        setViewControllers([nav1, nav2, nav3], animated: true)
        
    }
    
}
