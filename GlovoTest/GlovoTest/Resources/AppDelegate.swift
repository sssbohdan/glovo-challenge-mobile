//
//  AppDelegate.swift
//  GlovoTest
//
//  Created by Bohdan Savych on 4/13/19.
//  Copyright © 2019 bbb. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let googleMapsApiKey = "AIzaSyDxaGHHhtygiTQKSAwRCjhdRBk8v88nV48"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        GMSServices.provideAPIKey(googleMapsApiKey)

        let mapViewController = ViewControllerCreator.createHome()
        let navigation = UINavigationController(rootViewController: mapViewController)
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()

        return true
    }
}

