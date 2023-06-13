import UIKit

class ScheduleCell: UITableViewCell {

    static let identifier = "ScheduleCell"
    var delegate: ScheduleCellDelegate?
    var title: UILabel!
    var switcher: UISwitch!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 17)
        title.textColor = .black
        contentView.addSubview(title)

        switcher = UISwitch()
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.onTintColor = .blue
        switcher.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        contentView.addSubview(switcher)

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
    }

    @objc private func switchValueChanged(sender: UISwitch) {
        delegate?.switchValueChanged(for: sender.tag, value: switcher.isOn)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.5),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            switcher.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
