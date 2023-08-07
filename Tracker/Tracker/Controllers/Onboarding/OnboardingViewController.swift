import UIKit

final class OnboardingViewController: UIPageViewController {
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private lazy var goToTrackers: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(goToTrackersTapped), for: .touchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()

    private lazy var pages: [UIViewController] = {
        return [
            OnboardingFirstViewController(),
            OnboardingSecondViewController()
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        self.dataSource = self
        self.delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }

    private func setupView() {
        view.addSubview(pageControl)
        view.addSubview(goToTrackers)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            goToTrackers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            goToTrackers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            goToTrackers.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            goToTrackers.heightAnchor.constraint(equalToConstant: 60),
            pageControl.bottomAnchor.constraint(equalTo: goToTrackers.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


    @objc
    private func goToTrackersTapped() {
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = (UIApplication.shared.delegate as! AppDelegate).trackersTabBarController
        window.makeKeyAndVisible()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        var previousIndex = viewControllerIndex - 1
        if previousIndex < 0 { previousIndex = pages.count - 1 }
        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        var nextIndex = viewControllerIndex + 1
        if nextIndex == pages.count { nextIndex = 0 }
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

