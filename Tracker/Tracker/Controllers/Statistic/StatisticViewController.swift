import UIKit

final class StatisticViewController: UIViewController {

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "emptyStatisticImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers.emptyList", comment: "No completed trackers message")
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        table.separatorStyle = .none
        table.allowsSelection = false
        table.backgroundColor = UIColor(named: "white")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private var recordStore: RecordStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        recordStore = RecordStore(delegate: self)

        tableView.dataSource = self
        tableView.delegate = self

        setupView()
        setConstraints()
        setupStubImageVisibility()
    }

    private func setupView() {
        view.backgroundColor = UIColor(named: "white")
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("statistic", comment: "Title of Statistic VC")

        view.addSubview(imageView)
        view.addSubview(messageLabel)
        view.addSubview(tableView)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func setupStubImageVisibility() {
        guard let recordStore = recordStore else {
            return
        }

        tableView.isHidden = recordStore.isEmpty()
        imageView.isHidden = !tableView.isHidden
        messageLabel.isHidden = imageView.isHidden
    }

}

extension StatisticViewController: StoreDelegate {
    func didUpdate() {
        tableView.reloadData()
    }
}

extension StatisticViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatisticCell.identifier, for: indexPath)
        guard let cell = cell as? StatisticCell else {
            return UITableViewCell()
        }

        guard let recordStore = recordStore else {
            return cell
        }

        cell.amountOfCompletedTrackersLabel.text = "\(recordStore.trackersCompleted())"
        return cell
    }
}

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}


