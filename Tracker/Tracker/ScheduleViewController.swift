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
        view.addSubview(titleLabel)

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .green
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)


        confirmButton = UIButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Готово", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = .black
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 16
        view.addSubview(confirmButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -39),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
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
        cell.delegate = self
        return cell
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

protocol ScheduleCellDelegate {
    func switchValueChanged(for row: Int, value: Bool)
}

extension ScheduleViewController: ScheduleCellDelegate {
    func switchValueChanged(for row: Int, value: Bool) {
        let weekDay = weekDays[row]
        schedule[weekDay] = value
    }


}
