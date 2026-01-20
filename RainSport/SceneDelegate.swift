//
//  SceneDelegate.swift
//  RainSport
//
//  Created by Aleksandr on 09.12.2025.
//

import UIKit
import SwiftUI
import AppsFlyerLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Используем VortexAppRouter как корневой контроллер
        let router = VortexAppRouter()
        let hostingController = UIHostingController(rootView: router)
        
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        self.window = window
        
        // Обрабатываем deep links для AppsFlyer (если есть)
        if let userActivity = connectionOptions.userActivities.first {
            handleUserActivity(userActivity)
        }
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            handleURL(url)
        }
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        if userActivity.webpageURL != nil {
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
            }
        }
        
    private func handleURL(_ url: URL) {
        AppsFlyerLib.shared().handleOpen(url, options: [:])
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

