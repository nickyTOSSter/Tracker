import UIKit
import YandexMobileMetrica

class TrackersViewController: UIViewController {

    private var currentDate: Date = Date()
    private var messageLabel: UILabel!

    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = UIColor(named: "white")
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

    private var filterButton = UIButton()

    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private let searchController = UISearchController(searchResultsController: nil)

    private var trackerStore: TrackerStore?
    private var recordStore: RecordStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "white")

        trackerStore = TrackerStore(delegate: self)
        recordStore = RecordStore(delegate: self)

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
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "Search field placeholder")
        searchController.definesPresentationContext = true
        searchController.searchBar.searchTextField.clearButtonMode = .never
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController!.navigationBar.sizeToFit()
    }

    override func viewDidAppear(_ animated: Bool) {
        let params : [AnyHashable : Any] = ["screen": "Main"]
        YMMYandexMetrica.reportEvent("open", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        let params : [AnyHashable : Any] = ["screen": "Main"]
        YMMYandexMetrica.reportEvent("close", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
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

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        title = NSLocalizedString("trackers", comment: "Title of Trackers VC")
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    @objc private func addButtonTapped() {
        let params : [AnyHashable : Any] = ["screen": "Main", "item": "add_track"]
        YMMYandexMetrica.reportEvent("click", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })

        let vc = TrackerTypeSelectionViewController()
        vc.modalPresentationStyle = .automatic
        vc.delegate = self
        present(vc, animated: true)
    }

    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        currentDate = datePicker.date
        filterTrackers(with: searchController.searchBar.text)
    }

    @objc private func filterButtonTapped() {
        let params : [AnyHashable : Any] = ["screen": "Main", "item": "filter"]
        YMMYandexMetrica.reportEvent("click", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
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
        filterButton.isHidden = !imageView.isHidden
        if let searchText = searchController.searchBar.text, searchText.isEmpty == false {
            messageLabel.text = NSLocalizedString("trackers.filter.emptyList", comment: "Filter didn't find any trackers")
            imageView.image = UIImage(named: "emptySearch")

        } else {
            messageLabel.text = NSLocalizedString("trackers.emptyList", comment: "User don't create any trackers")
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
    func trackerWasEdited(category: TrackerCategory, tracker: Tracker)
}

extension TrackersViewController: TrackerAdditionDelegate {
    func trackerWasCreated(category: TrackerCategory, tracker: Tracker) {
        trackerStore?.add(tracker, to: category)
        filterTrackers(with: searchController.searchBar.text)
        reloadCollectionView()
    }

    func trackerWasEdited(category: TrackerCategory, tracker: Tracker) {
        trackerStore?.edit(tracker, to: category)
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
        let dayStatisticText = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of days task was done"),
            amountOfCompletedDays(for: tracker)
        )
        cell.statisticLabel.text = dayStatisticText
        cell.completeButton.backgroundColor = tracker.color
        let completed = trackerIsCompletedOnChosenDate(tracker)
        let btnImage = UIImage(named: completed ? "done" : "plus")
        cell.completeButton.setImage(btnImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.completeButton.backgroundColor = cell.completeButton.backgroundColor?.withAlphaComponent(completed ? 0.5 : 1)
        cell.isPinnedImageView.isHidden = tracker.isPinned ? false : true
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
        view.titleLabel.text = trackerStore?.sectionName(at: indexPath)
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

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first, let isPinned = trackerStore?.object(at: indexPath)?.isPinned else {
            return UIContextMenuConfiguration()
        }

        var toggleTrackerPinActionTitle = isPinned
            ? NSLocalizedString("unpin", comment: "Title for pinned tracker")
            : NSLocalizedString("pin", comment: "Title for unpinned tracker")

        let toggleTrackerPinAction = UIAction(title: toggleTrackerPinActionTitle) { [weak self] _ in
            self?.toggleTrackerPin(at: indexPath)
        }

        let editAction = UIAction(title: NSLocalizedString("edit", comment: "Title for edit tracker button")) { [weak self] _ in
            self?.editItem(at: indexPath)
        }

        let deleteAction = UIAction(title: NSLocalizedString("delete", comment: "Title for delete tracker button"), attributes: .destructive) { [weak self] _ in
            self?.deleteItem(at: indexPath)
        }

        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [toggleTrackerPinAction, editAction, deleteAction])
        }
        return configuration

    }

    private func toggleTrackerPin(at indexPath: IndexPath) {
        self.trackerStore?.toggleTrackerPin(at: indexPath)
    }

    private func editItem(at indexPath: IndexPath) {
        let params : [AnyHashable : Any] = ["screen": "Main", "item": "edit"]
        YMMYandexMetrica.reportEvent("click", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })

        guard let tracker = trackerStore?.object(at: indexPath) else {
            return
        }

        let vc = HabitEditingViewController()
        vc.tracker = tracker
        vc.category = trackerStore?.category(at: indexPath)
        vc.dayStatisticText = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of days task was done"),
            amountOfCompletedDays(for: tracker)
        )

        vc.modalPresentationStyle = .automatic
        vc.delegate = self
        present(vc, animated: true)
    }

    private func deleteItem(at indexPath: IndexPath) {
        let params : [AnyHashable : Any] = ["screen": "Main", "item": "delete"]
        YMMYandexMetrica.reportEvent("click", parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })


        let deleteConfirmationAlert = UIAlertController(title: NSLocalizedString("deleteConfirmationQuestion", comment: "Tracker removal confirmation question"),
                                                        message: nil,
                                                        preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: NSLocalizedString("delete", comment: "Title for delete tracker button"), style: .destructive) { [weak self] _ in
            guard let self = self else { return }

            self.trackerStore?.delete(at: indexPath)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "Title for cancel tracker button"), style: .cancel)

        deleteConfirmationAlert.addAction(deleteAction)
        deleteConfirmationAlert.addAction(cancelAction)
        present(deleteConfirmationAlert, animated: true, completion: nil)
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
        messageLabel.text = NSLocalizedString("trackers.emptyList", comment: "User don't create any trackers")
        messageLabel.font = UIFont.boldSystemFont(ofSize: 12)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)

        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = UIColor(red: 0.22, green: 0.45, blue: 0.91, alpha: 1)
        filterButton.setTitle(NSLocalizedString("filter", comment: "Filter button title"), for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.textAlignment = .center
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)

        filterButton.layer.cornerRadius = 16
        filterButton.layer.masksToBounds = true

        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        view.addSubview(filterButton)

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
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
        reloadCollectionView()
    }
}
