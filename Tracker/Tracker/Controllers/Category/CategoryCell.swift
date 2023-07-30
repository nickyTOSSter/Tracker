import UIKit

class CategoryCell: UITableViewCell {

    static let identifier = "CategoryCell"
    var title: UILabel!
    var checkImageView: UIImageView!

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

        checkImageView = UIImageView(image: UIImage(named: "check"))
        checkImageView.isHidden = true
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(checkImageView)

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkImageView.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            checkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
