
import UIKit

class RegularEventViewController: UIViewController {

    private var titleLabel: UILabel!
    private var nameTextField: UITextField!
    private var tableView: UITableView!
    private var cancelButton: UIButton!
    private var createButton: UIButton!
    private var inputContainer: UIView!
    private var listItems = ["Категория", "Расписание"]
    private var schedule: [WeekDay: Bool] = WeekDay.scheduleTemplate()
    private var category: String = "Важное"
    weak var delegate: TrackerAdditionDelegate?
    private var allIsGood: Bool {
        get {
            guard let trackerName = nameTextField.text else {
                return false
            }

            let selectedWeekDays = schedule.filter({ element in
                element.value
            })
            return trackerName.isEmpty == false &&
                selectedWeekDays.isEmpty == false &&
                category.isEmpty == false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraits()
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
     }

    @objc private func createButtonTapped() {
        guard let trackerName = nameTextField.text else {
            return
        }

        let newTracker = Tracker(name: trackerName, color: .dodgerBlue, emoji: "😀", schedule: schedule)
        delegate?.trackerWasCreated(categoryName: category, tracker: newTracker)
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }

    private func selectSchedule() {
        let vc = ScheduleViewController()
        vc.delegate = self
        vc.schedule = schedule
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }

    private func setScheduleDescription() -> String {
        var description = ""
        let selectedDays = schedule.filter({ element in
            element.value
        })
        if selectedDays.count == 7 {
            return "Каждый день"
        }


        for (weekDay, selected) in schedule where selected {
            description += weekDay.shortDescription() + ", "
        }
        if !description.isEmpty {
            description.removeLast(2)
        }
        return description
    }

    private func allPropertiesAreFilled() -> Bool {
        guard let trackerName = nameTextField.text else {
            return false
        }

        let selectedWeekDays = schedule.filter({ element in
            element.value
        })

        return trackerName.isEmpty == false &&
            selectedWeekDays.isEmpty == false &&
            category.isEmpty == false
    }

    private func setCreationButtonAccessibility() {
        if allIsGood {
            createButton.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
            createButton.isEnabled = false
        }
    }

}

extension RegularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let defaultRowHeight: CGFloat = 75
        return defaultRowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {

        } else if indexPath.row == 1 {
            selectSchedule()
        }
    }
}

extension RegularEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventCreationTableViewCell.identifier, for: indexPath) as? EventCreationTableViewCell else {
            return UITableViewCell()
        }
        cell.title.text = listItems[indexPath.row]

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none

        if indexPath.row == 0 {
            cell.subtitle.text = category
        } else if indexPath.row == 1 {
            addSeparator(for: cell)
            cell.subtitle.text = setScheduleDescription()
         }

        cell.backgroundColor = UIColor(red: 0.902, green: 0.910, blue: 0.922, alpha: 0.3)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listItems.count
    }

}

extension RegularEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 38
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        return newString.count <= maxLength
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameTextField.text = ""
        setCreationButtonAccessibility()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        setCreationButtonAccessibility()
        return true
    }
}

protocol ScheduleDelegate: AnyObject {
    func scheduleHasBeenSet(schedule: [WeekDay: Bool])
}

extension RegularEventViewController: ScheduleDelegate {
    func scheduleHasBeenSet(schedule: [WeekDay : Bool]) {
        self.schedule = schedule
        setCreationButtonAccessibility()
        tableView.reloadData()
    }
}

// MARK: - UI elemets creation
extension RegularEventViewController {
    private func setupViews() {
        view.backgroundColor = .white

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Новая привычка"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)

        inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        inputContainer.layer.masksToBounds = true
        inputContainer.layer.cornerRadius = 16


        nameTextField = UITextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = "Введите название трекера"
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        nameTextField.enablesReturnKeyAutomatically = true
        inputContainer.addSubview(nameTextField)
        view.addSubview(inputContainer)

        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.masksToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.register(EventCreationTableViewCell.self, forCellReuseIdentifier: EventCreationTableViewCell.identifier)
        tableView.isScrollEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1), for: .normal)
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1).cgColor
        view.addSubview(cancelButton)

        createButton = UIButton()
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        setCreationButtonAccessibility()
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        view.addSubview(createButton)

    }

    private func setupConstraits() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 122),
            inputContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            inputContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            inputContainer.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            cancelButton.widthAnchor.constraint(equalToConstant: 161),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -21),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -21),
            createButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
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
