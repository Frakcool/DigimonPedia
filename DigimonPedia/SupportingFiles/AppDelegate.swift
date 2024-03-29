//
//  AppDelegate.swift
//  DigimonPedia
//
//  Created by Jesus Sanchez on 23/01/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let _ = CoreDataManager.shared.persistentContainer

        let persistentCacheManager: PersistentCacheManager = DigimonFileManager.shared
        let viewModel = MainViewViewModel(persistentCacheManager: persistentCacheManager)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController(viewModel: viewModel)
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the managed object context before the application terminates.
        CoreDataManager.shared.saveContext()
    }
}
