import UIKit

final class StatisticCell: UITableViewCell {
    static let identifier = "statisticCell"

    let amountOfCompletedTrackersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistic.trackersCompleted", comment: "Completed trackers label")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(amountOfCompletedTrackersLabel)
        contentView.addSubview(label)

        let gradient = CAGradientLayer()
         gradient.colors = [
            UIColor(red: 249 / 255, green: 77 / 255, blue: 73 / 255, alpha: 1).cgColor,
            UIColor(red: 56 / 255, green: 208 / 255, blue: 177 / 255, alpha: 1).cgColor,
            UIColor(red: 91 / 255, green: 92 / 255, blue: 253 / 255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.frame = CGRect(x: 0, y: 0, width: bounds.width + 41, height: bounds.height)
        UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, false, 0)
        gradient.render(in: UIGraphicsGetCurrentContext()!)

        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        contentView.backgroundColor = UIColor(named: "white")
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor(patternImage: gradientImage!).cgColor
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            amountOfCompletedTrackersLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            amountOfCompletedTrackersLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.topAnchor.constraint(equalTo: amountOfCompletedTrackersLabel.bottomAnchor, constant: 12)
        ])
    }

}
