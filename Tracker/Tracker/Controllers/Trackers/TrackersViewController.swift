import UIKit

class TrackersViewController: UIViewController {

    private var currentDate: Date = Date()
    private var messageLabel: UILabel!

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            TrackerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSupplementaryView.identifier
        )
        return collectionView
    }()

    private lazy var imageView: UIImageView! = {
        UIImageView(image: UIImage(named: "emptyListImage"))
    }()

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var trackerStore: TrackerStore?
    private var recordStore: RecordStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "white")

        trackerStore = TrackerStore(delegate: self)
        recordStore = RecordStore(delegate: self)

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        visibleCategories = categories
        setupViews()
        setupConstraits()

        collectionView.dataSource = self
        collectionView.delegate = self
        setupStubImageVisibility()
        filterTrackers(with: searchController.searchBar.text)
        navigationController?.navigationBar.prefersLargeTitles = true
        setNavBarElements()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.definesPresentationContext = true
        searchController.searchBar.searchTextField.clearButtonMode = .never
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController!.navigationBar.sizeToFit()
    }

    private func setNavBarElements() {
        let addNewTrackerButton: UIBarButtonItem = {
            let barButton = UIBarButtonItem()
            barButton.tintColor = UIColor(named: "black")
            barButton.style = .plain
            barButton.image = UIImage(named: "plus")
            barButton.target = self
            barButton.action = #selector(addButtonTapped)
            return barButton
        }()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        let datePicker = UIDatePicker()
        datePicker.locale = dateFormatter.locale
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        title = "Трекеры"
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    @objc private func addButtonTapped() {
        let vc = TrackerTypeSelectionViewController()
        vc.modalPresentationStyle = .automatic
        vc.delegate = self
        present(vc, animated: true)
    }

    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date
        filterTrackers(with: searchController.searchBar.text)
    }

    private func filterTrackers(with name: String?) {
        trackerStore!.filter(by: currentDate, and: searchController.searchBar.text!)
        reloadCollectionView()
    }

    private func reloadCollectionView() {
        collectionView.reloadData()
        setupStubImageVisibility()
    }

    private func setupStubImageVisibility() {
        imageView.isHidden = !trackerStore!.isEmpty()
        messageLabel.isHidden = imageView.isHidden
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false {
            messageLabel.text = "Ничего не найдено"
            imageView.image = UIImage(named: "emptySearch")

        } else {
            messageLabel.text = "Что будем отслеживать?"
            imageView.image = UIImage(named: "emptyListImage")
        }
    }

    private func trackerIsCompletedOnChosenDate(_ tracker: Tracker) -> Bool {
        guard let dateWithoutTime = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: currentDate)) else {
            return false
        }


        if let _ = recordStore!.object(by: tracker.id, and: dateWithoutTime) {
            return true
        } else {
            return false
        }
    }

    private func amountOfCompletedDays(for tracker: Tracker) -> Int {
        return recordStore!.amaountOfCompletedTrackers(by: tracker.id)
    }
}

protocol TrackerAdditionDelegate: AnyObject {
    func trackerWasCreated(category: TrackerCategory, tracker: Tracker)
}

extension TrackersViewController: TrackerAdditionDelegate {
    func trackerWasCreated(category: TrackerCategory, tracker: Tracker) {
        trackerStore?.add(tracker, to: category)
        filterTrackers(with: searchController.searchBar.text)
        reloadCollectionView()
    }
}

protocol TrackerCellDelegate: AnyObject {
    func trackerCompletedButtonTapped(indexPath: IndexPath)
}

extension TrackersViewController: TrackerCellDelegate {
    func trackerCompletedButtonTapped(indexPath: IndexPath) {

        guard let dateWithoutTime = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: currentDate)),
              let todayWithoutTime = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Date())),
              dateWithoutTime <= todayWithoutTime else {
            return
        }

        guard let tracker = trackerStore?.object(at: indexPath) else {
            return
        }

        if let record = recordStore!.object(by: tracker.id, and: dateWithoutTime) {
            recordStore!.delete(record)
        } else {
            recordStore?.add(TrackerRecord(id: tracker.id, completionDate: dateWithoutTime))
        }

        collectionView.reloadData()
    }

}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
         trackerStore!.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore!.numberOfRowsInSection(section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as! TrackerCollectionViewCell
        guard let tracker = trackerStore!.object(at: indexPath) else { return cell }
        cell.descriptionLabel.text = tracker.name
        cell.card.backgroundColor = tracker.color
        cell.emojiLabel.text = tracker.emoji
        cell.statisticLabel.text = "\(amountOfCompletedDays(for: tracker)) дней"
        cell.completeButton.backgroundColor = tracker.color
        let completed = trackerIsCompletedOnChosenDate(tracker)
        let btnImage = UIImage(named: completed ? "done" : "plus")
        cell.completeButton.setImage(btnImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.completeButton.backgroundColor = cell.completeButton.backgroundColor?.withAlphaComponent(completed ? 0.5 : 1)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width - 32 - 9) / 2, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = TrackerSupplementaryView.identifier
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! TrackerSupplementaryView
        view.titleLabel.text = trackerStore?.category(at: indexPath)?.name
        return view
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - UI elemets creation
extension TrackersViewController {
    private func setupViews() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        messageLabel = UILabel()
        messageLabel.text = "Что будем отслеживать?"
        messageLabel.font = UIFont.boldSystemFont(ofSize: 12)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
    }

    private func setupConstraits() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       filterTrackers(with: searchController.searchBar.text)
    }
}

extension TrackersViewController: StoreDelegate {
    func didUpdate() {
        collectionView.reloadData()
    }
}
