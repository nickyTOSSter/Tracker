import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        let trackerlistViewController = TrackersViewController()
        trackerlistViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tabBar_trackers"), tag: 0)

        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "tabBar_statistic"), tag: 0)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: trackerlistViewController),
            UINavigationController(rootViewController: statisticViewController)
        ]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

}
