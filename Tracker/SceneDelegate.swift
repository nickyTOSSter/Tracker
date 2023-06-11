import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()



        let trackerlistViewController = TrackersViewController()
        trackerlistViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tabBar_trackers"), tag: 0)
        let trackerListNavigationVC = UINavigationController(rootViewController: trackerlistViewController)

        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "tabBar_statistic"), tag: 0)
        let statisticNavigationVC = UINavigationController(rootViewController: statisticViewController)

        tabBarController.viewControllers = [trackerListNavigationVC, statisticNavigationVC]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}

