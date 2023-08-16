import UIKit
import CoreData
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {                              
                fatalError("failed to load container")
            }
        }
        return container
    }()

    lazy var trackersTabBarController: UITabBarController = {
        let trackerlistViewController = TrackersViewController()
        trackerlistViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers", comment: "Trackers tab bar"), image: UIImage(named: "tabBar_trackers"), tag: 0)

        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers.tabBar.right", comment: "Statistics tab bar"), image: UIImage(named: "tabBar_statistic"), tag: 0)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: trackerlistViewController),
            UINavigationController(rootViewController: statisticViewController)
        ]
        return tabBarController
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let configuration = YMMYandexMetricaConfiguration(apiKey: "bd9997ef-de33-4a68-b7da-54be4633b18e") {
            YMMYandexMetrica.activate(with: configuration)
        }

        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
