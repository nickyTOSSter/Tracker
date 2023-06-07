import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let identifier = "trackerCell"

    let card = UIView()
    let emojiViewContainer = UIView()
    let emojiLabel = UILabel()
    let descriptionLabel = UILabel()
    let statisticLabel = UILabel()
    let completeButton = UIButton()
    //var completed: Bool = false
    weak var delegate: TrackerCellDelegate?
    var indexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraits()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        setupCard()
        setupStatistic()
        setupCompleteButton()
    }

    private func setupCard() {
        card.translatesAutoresizingMaskIntoConstraints = false

        setupEmoji()
        setupDescription()

        card.layer.masksToBounds = true
        card.layer.cornerRadius = 16
        contentView.addSubview(card)
    }

    private func setupEmoji() {
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiViewContainer.translatesAutoresizingMaskIntoConstraints = false

        emojiViewContainer.backgroundColor = UIColor(white: 1, alpha: 0.3)
        emojiViewContainer.layer.masksToBounds = true
        emojiViewContainer.layer.cornerRadius = 12

        emojiLabel.font = emojiLabel.font.withSize(16)
        emojiLabel.textAlignment = .center

        emojiViewContainer.addSubview(emojiLabel)
        card.addSubview(emojiViewContainer)
    }

    private func setupDescription() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.font = descriptionLabel.font.withSize(12)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .left
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 2

        card.addSubview(descriptionLabel)
    }
    private func setupStatistic() {
        statisticLabel.translatesAutoresizingMaskIntoConstraints = false

        statisticLabel.font = statisticLabel.font.withSize(12)

        contentView.addSubview(statisticLabel)
    }

    private func setupCompleteButton() {
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        //setCompleteButtonImage()
        completeButton.imageEdgeInsets = UIEdgeInsets(top: 11.72, left: 11.72, bottom: 11.72, right: 11.72)
        completeButton.layer.masksToBounds = true
        completeButton.layer.cornerRadius = 17
        completeButton.tintColor = .white
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        contentView.addSubview(completeButton)
    }

    private func setupConstraits() {
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            card.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            card.heightAnchor.constraint(equalToConstant: 90),
            emojiViewContainer.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            emojiViewContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            emojiViewContainer.widthAnchor.constraint(equalToConstant: 24),
            emojiViewContainer.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiViewContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiViewContainer.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 22),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            descriptionLabel.topAnchor.constraint(equalTo: emojiViewContainer.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            statisticLabel.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 16),
            statisticLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            statisticLabel.heightAnchor.constraint(equalToConstant: 18),

            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: statisticLabel.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    @objc private func completeButtonTapped() {
        guard let indexPath = indexPath else {
            return
        }
//        completed.toggle()
//        setCompleteButtonImage()
        delegate?.trackerCompletedButtonTapped(indexPath: indexPath)
    }

//    private func setCompleteButtonImage() {
//        let btnImage = UIImage(named: completed ? "done" : "plus")
//        completeButton.setImage(btnImage?.withRenderingMode(.alwaysTemplate), for: .normal)
//        completeButton.backgroundColor = completeButton.backgroundColor?.withAlphaComponent(completed ? 0.5 : 1)
//    }

}
