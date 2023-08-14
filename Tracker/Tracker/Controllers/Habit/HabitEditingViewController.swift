
import UIKit

class HabitEditingViewController: UIViewController {

    var tracker: Tracker?
    var category: TrackerCategory?
    var dayStatisticText: String?

    private var titleLabel: UILabel!
    private var dayStatisticLabel: UILabel!
    private var nameTextField: UITextField!
    private var tableView: UITableView!
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.backgroundColor = UIColor(named: "white")
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(NewTrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewTrackerSupplementaryView.identifier)
        return collectionView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor(named: "white")
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private var cancelButton: UIButton!
    private var saveButton: UIButton!
    private var inputContainer: UIView!
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var trackerSelectedEmojiIndexPath: IndexPath?
    private var trackerSelectedColorIndexPath: IndexPath?
    weak var delegate: TrackerAdditionDelegate?

    var creationManager = CreationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let tracker = tracker else {
            dismiss(animated: true)
            return
        }

        creationManager.name = tracker.name
        creationManager.selectedColor = tracker.color
        creationManager.selectedEmoji = tracker.emoji
        creationManager.schedule = tracker.schedule
        creationManager.category = category

        setupViews()
        setupConstraits()
        
        nameTextField.text = creationManager.name

        if let selectedEmoji = creationManager.selectedEmoji, let indexOfEmoji = creationManager.emojies.firstIndex(of: selectedEmoji) {
            trackerSelectedEmojiIndexPath = IndexPath(item: indexOfEmoji, section: 0)
        }

        if let selectedColor = creationManager.selectedColor {
            let hexColor = ColorMarshall.shared.encode(color: selectedColor)
            if let indexOfColor = creationManager.colorsHex.firstIndex(of: hexColor) {
                trackerSelectedColorIndexPath = IndexPath(item: indexOfColor, section: 1)
            }
        }

    }

    override func viewDidAppear(_ animated: Bool) {
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let tracker = tracker,
              let tracker = creationManager.newTracker(id: tracker.id, isPinned: tracker.isPinned) else {
            return
        }

        delegate?.trackerWasEdited(category: creationManager.category!, tracker: tracker)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }

    private func selectSchedule() {
        let vc = ScheduleViewController()
        vc.delegate = self
        vc.schedule = creationManager.schedule
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }

    private func setCreationButtonAccessibility() {
        if creationManager.isReadyForCreation() {
            saveButton.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
            saveButton.isEnabled = false
        }
    }

    private func selectCategory() {
        let vc = CategoryViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }
}

extension HabitEditingViewController: CategoryViewControllerDelegate {
    func categoryDidSelect(_ category: TrackerCategory) {
        creationManager.category = category
        tableView.reloadData()
    }
}

extension HabitEditingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultRowHeight: CGFloat = 75
        return defaultRowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if creationManager.isSchedule(row: indexPath.row) {
            selectSchedule()
        } else {
            selectCategory()
        }
    }
}

extension HabitEditingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventCreationTableViewCell.identifier, for: indexPath) as? EventCreationTableViewCell else {
            return UITableViewCell()
        }
        cell.title.text = creationManager.listItems[indexPath.row]

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        if creationManager.isSchedule(row: indexPath.row) {
            addSeparator(for: cell)
            cell.subtitle.text = creationManager.getScheduleDescription()

        } else {
            if let category = creationManager.category {
                cell.subtitle.text = creationManager.category?.name
            }
        }

        cell.backgroundColor = UIColor(red: 0.902, green: 0.910, blue: 0.922, alpha: 0.3)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        creationManager.listItems.count
    }

}

extension HabitEditingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameTextField.text = ""
        creationManager.name = ""
        setCreationButtonAccessibility()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        creationManager.name = nameTextField.text ?? ""
        setCreationButtonAccessibility()
        return true
    }
}

extension HabitEditingViewController: ScheduleDelegate {
    func scheduleHasBeenSet(schedule: [WeekDay]) {
        creationManager.schedule = schedule
        setCreationButtonAccessibility()
        tableView.reloadData()
    }
}

// MARK: - UI elemets creation
extension HabitEditingViewController {
    private func setupViews() {
        view.backgroundColor = .white

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("habitEditing", comment: "Title of habit editing view controller")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)

        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: view.frame.height)
        view.addSubview(scrollView)

        dayStatisticLabel = UILabel()
        dayStatisticLabel.translatesAutoresizingMaskIntoConstraints = false
        dayStatisticLabel.text = dayStatisticText
        dayStatisticLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        scrollView.addSubview(dayStatisticLabel)

        inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        inputContainer.layer.masksToBounds = true
        inputContainer.layer.cornerRadius = 16


        nameTextField = UITextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = NSLocalizedString("creation.placeholder", comment: "Tracker name textfield placeholder")
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        nameTextField.enablesReturnKeyAutomatically = true
        inputContainer.addSubview(nameTextField)
        scrollView.addSubview(inputContainer)

        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.register(EventCreationTableViewCell.self, forCellReuseIdentifier: EventCreationTableViewCell.identifier)
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.addSubview(tableView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        collectionView.register(NewTrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewTrackerSupplementaryView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        scrollView.addSubview(collectionView)

        cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.setTitle(NSLocalizedString("creation.cancel", comment: "Cancel button title"), for: .normal)
        cancelButton.setTitleColor(UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1), for: .normal)
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1).cgColor
        view.addSubview(cancelButton)

        saveButton = UIButton()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        saveButton.setTitle(NSLocalizedString("save", comment: "Save button title"), for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        setCreationButtonAccessibility()
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 16
        view.addSubview(saveButton)

    }

    private func setupConstraits() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            dayStatisticLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            dayStatisticLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            inputContainer.topAnchor.constraint(equalTo: dayStatisticLabel.bottomAnchor, constant: 40),
            inputContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            inputContainer.heightAnchor.constraint(equalToConstant: 75),

            nameTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            tableView.heightAnchor.constraint(equalToConstant: 150),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -21),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 161),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -21),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }

    private func addSeparator(for cell: UITableViewCell) {
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 1))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .gray
        cell.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: cell.topAnchor),
            separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }
}

extension HabitEditingViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id = ""
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = NewTrackerSupplementaryView.identifier
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! NewTrackerSupplementaryView

        if indexPath.section == 0 {
            view.titleLabel.text = NSLocalizedString("creation.emoji", comment: "Emoji collection title")
        } else {
            view.titleLabel.text = NSLocalizedString("creation.color", comment: "Color collection title")
        }
        return view
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }

            cell.emojiLabel.text = creationManager.emojies[indexPath.row]
            if let trackerSelectedEmojiIndexPath = trackerSelectedEmojiIndexPath {
                setEmojiCellBackground(for: cell, at: trackerSelectedEmojiIndexPath)
                self.trackerSelectedEmojiIndexPath = nil
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }

            cell.colorContainer.backgroundColor = creationManager.colors[indexPath.row]
            if let trackerSelectedColorIndexPath = trackerSelectedColorIndexPath {
                setColorCellBackground(for: cell, at: trackerSelectedColorIndexPath)
                self.trackerSelectedColorIndexPath = nil
            }

            return cell
        }

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
//            if let selectedEmojiIndexPath = selectedEmojiIndexPath {
//                let cell = collectionView.cellForItem(at: selectedEmojiIndexPath) as! EmojiCell
//                cell.emojiContainer.backgroundColor = .white
//            }
//
            let cell = collectionView.cellForItem(at: indexPath) as! EmojiCell
//            cell.emojiContainer.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 1)
//            creationManager.selectedEmoji = creationManager.emojies[indexPath.row]
//            selectedEmojiIndexPath = indexPath
            diselectEmojiCell()
            setEmojiCellBackground(for: cell, at: indexPath)
        } else {

//            if let selectedColorIndexPath = selectedColorIndexPath {
//                let cell = collectionView.cellForItem(at: selectedColorIndexPath) as! ColorCell
//                cell.selectionContainer.layer.borderColor = UIColor.clear.cgColor
//            }
//
//            let color = creationManager.colors[indexPath.row]
            let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
//            cell.selectionContainer.layer.borderColor = color.withAlphaComponent(0.3).cgColor
//
//            creationManager.selectedColor = color
//            selectedColorIndexPath = indexPath
            diselectColorCell()
            setColorCellBackground(for: cell, at: indexPath)
        }
        setCreationButtonAccessibility()
        collectionView.deselectItem(at: indexPath, animated: false)
    }

    private func diselectEmojiCell() {
        if let selectedEmojiIndexPath = selectedEmojiIndexPath {
            let cell = collectionView.cellForItem(at: selectedEmojiIndexPath) as! EmojiCell
            cell.emojiContainer.backgroundColor = .white
        }
    }

    private func diselectColorCell() {
        if let selectedColorIndexPath = selectedColorIndexPath {
            let cell = collectionView.cellForItem(at: selectedColorIndexPath) as! ColorCell
            cell.selectionContainer.layer.borderColor = UIColor.clear.cgColor
        }
    }


    private func setEmojiCellBackground(for cell: EmojiCell, at indexPath: IndexPath) {
        cell.emojiContainer.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 1)
        creationManager.selectedEmoji = creationManager.emojies[indexPath.row]
        selectedEmojiIndexPath = indexPath
    }

    private func setColorCellBackground(for cell: ColorCell, at indexPath: IndexPath) {
        let color = creationManager.colors[indexPath.row]
        cell.selectionContainer.layer.borderColor = color.withAlphaComponent(0.3).cgColor

        creationManager.selectedColor = color
        selectedColorIndexPath = indexPath
    }

}

extension HabitEditingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
}
