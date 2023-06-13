import UIKit

class ScheduleViewController: UIViewController {

    private var titleLabel: UILabel!
    private var confirmButton: UIButton!
    private var tableView: UITableView!
    private let weekDays: [WeekDay] = [
        .monday, .tuesday, .wednesday, .thursday,
        .friday, .saturday, .sunday
    ]
    var schedule: [WeekDay: Bool]!

    weak var delegate: ScheduleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }
    private func setupViews() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Расписание"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)


        confirmButton = UIButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Готово", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        confirmButton.backgroundColor = .black
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 16
        view.addSubview(confirmButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -24),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 60)
        ])

    }

    @objc private func confirmButtonTapped() {
        dismiss(animated: true)
        delegate?.scheduleHasBeenSet(schedule: schedule)
    }

}

extension ScheduleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        let weekDay = weekDays[indexPath.row]
        cell.title.text = weekDay.description()
        let weekDayIsSelected = schedule[weekDay, default: false]
        cell.switcher.isOn = weekDayIsSelected
        cell.switcher.tag = indexPath.row
        if indexPath.row != 0 {
            addSeparator(for: cell)
        }
        if indexPath.row == weekDays.count - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        }
        cell.delegate = self
        cell.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        return cell
    }

    private func addSeparator(for cell: UITableViewCell) {
        let separator = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 1))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        cell.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: cell.topAnchor),
            separator.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}

protocol ScheduleCellDelegate {
    func switchValueChanged(for row: Int, value: Bool)
}

extension ScheduleViewController: ScheduleCellDelegate {
    func switchValueChanged(for row: Int, value: Bool) {
        let weekDay = weekDays[row]
        schedule[weekDay] = value
    }


}
