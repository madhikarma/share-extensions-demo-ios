//
//  SceneDelegate.swift
//  ShareDemo
//
//  Created by Shagun Madhikarmi on 07/05/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Called when opening a new scene

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        if let url = connectionOptions.urlContexts.first?.url {
            handleIncomingURL(url)
        } else {
            window = UIWindow(windowScene: windowScene)
            let viewController = ViewController()
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }
    }

    // Called on existing scenes
    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            handleIncomingURL(url)
        }
    }

    func handleIncomingURL(_ url: URL) {
        if let scheme = url.scheme,
           scheme.caseInsensitiveCompare("ShareExtension101") == .orderedSame,
           let page = url.host
        {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }

            print("redirect(to: \(page), with: \(parameters))")

            for parameter in parameters where parameter.key.caseInsensitiveCompare("url") == .orderedSame {
                UserDefaults().set(parameter.value, forKey: "incomingURL")
            }
        }
    }
}
