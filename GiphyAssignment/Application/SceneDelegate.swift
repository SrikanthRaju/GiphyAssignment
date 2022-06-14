//
//  SceneDelegate.swift
//  GiphyAssignment
//
//  Created by Sri on 10/06/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private func createTabBarController() -> UITabBarController {

        let imageFetcher = AsyncImageFetcher(concurrentOperations: 3, cacheImageCount: 10)
        let dataStore = StoreData.inDatabase
        let favRepo = FavouriteRepository(dataStore: dataStore)

        let apiService = GIFService()
        let gifRepo = GIFRepository(service: apiService)

        let homeVM = HomeViewModel(gifUseCase: gifRepo, favouriteUseCase: favRepo)
        let homeVC = HomeViewController(viewModel: homeVM, imageFetcher: imageFetcher)
        let homeNC = UINavigationController(rootViewController: homeVC)
        homeNC.tabBarItem = UITabBarItem(
            title: nil,
            image: .init(systemName: ImageAsserts.Icon.gifUnselected.imageName),
            selectedImage: .init(systemName: ImageAsserts.Icon.gifSelected.imageName))

        let favVM = FavoriteViewModel(favouriteUseCase: favRepo)
        let favVC = FavoriteViewController(viewModel: favVM, imageFetcher: imageFetcher)
        let favNC = UINavigationController(rootViewController: favVC)
        favNC.tabBarItem = UITabBarItem(
            title: nil,
            image: .init(systemName: ImageAsserts.Icon.favUnselected.imageName),
            selectedImage: .init(systemName: ImageAsserts.Icon.favSelected.imageName))

        let tabVC = UITabBarController()
        tabVC.viewControllers = [homeNC, favNC]

        return tabVC
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = createTabBarController()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
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

