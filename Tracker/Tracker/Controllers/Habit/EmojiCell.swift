import UIKit

class EmojiCell: UICollectionViewCell {

    static let identifier = "EmojiCell"

    var emojiLabel: UILabel!
    var emojiContainer: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        emojiContainer = UIView()
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiContainer.backgroundColor = .white
        emojiContainer.layer.masksToBounds = true
        emojiContainer.layer.cornerRadius = 16
        contentView.addSubview(emojiContainer)

        emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        emojiContainer.addSubview(emojiLabel)
        NSLayoutConstraint.activate([

            emojiContainer.widthAnchor.constraint(equalToConstant: 52),
            emojiContainer.heightAnchor.constraint(equalToConstant: 52),

            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            emojiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor)
        ])

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
