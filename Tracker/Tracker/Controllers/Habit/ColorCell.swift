import UIKit

class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"

    var selectionContainer: UIView!
    var colorContainer: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        selectionContainer = UIView()
        selectionContainer.translatesAutoresizingMaskIntoConstraints = false
        selectionContainer.backgroundColor = .white
        selectionContainer.layer.masksToBounds = true
        selectionContainer.layer.cornerRadius = 8
        selectionContainer.layer.borderWidth = 3
        selectionContainer.layer.borderColor = UIColor.clear.cgColor
        contentView.addSubview(selectionContainer)

        colorContainer = UIView()
        colorContainer.translatesAutoresizingMaskIntoConstraints = false
        colorContainer.backgroundColor = .white
        colorContainer.layer.masksToBounds = true
        colorContainer.layer.cornerRadius = 8
        selectionContainer.addSubview(colorContainer)


        NSLayoutConstraint.activate([

            selectionContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            colorContainer.leadingAnchor.constraint(equalTo: selectionContainer.leadingAnchor, constant: 6),
            colorContainer.trailingAnchor.constraint(equalTo: selectionContainer.trailingAnchor, constant: -6),
            colorContainer.topAnchor.constraint(equalTo: selectionContainer.topAnchor, constant: 6),
            colorContainer.bottomAnchor.constraint(equalTo: selectionContainer.bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
