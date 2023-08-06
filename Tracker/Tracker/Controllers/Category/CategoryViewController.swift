import UIKit

class CategoryViewController: UIViewController {
    private var titleLabel: UILabel!
    private var tableView: UITableView!
    private var addButton: UIButton!
    private lazy var imageView: UIImageView! = {
        UIImageView(image: UIImage(named: "emptyListImage"))
    }()
    private var messageLabel: UILabel!

    weak var delegate: CategoryViewControllerDelegate?
    private var viewModel: CategoryViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()

        viewModel = CategoryViewModel()
        bind()
     }

    private func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.$categoryIsEmpty.bind { [weak self] newValue in
            guard let self = self else { return }
            self.setupStubImageVisibility(newValue)
        }

        viewModel.$numberOfRowsInSection.bind { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }

        viewModel.initialize()
    }

    @objc private func addButtonTapped() {
        let vc = NewCategoryViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .automatic
        present(vc, animated: true)
    }

}

// MARK: - UI
extension CategoryViewController {
    private func setupViews() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        messageLabel = UILabel()
        messageLabel.font = UIFont.boldSystemFont(ofSize: 12)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        paragraphStyle.alignment = .center
        messageLabel.textAlignment = .center
        messageLabel.attributedText = NSMutableAttributedString(string: "Привычки и события можно  объединить по смыслу", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)

        addButton = UIButton()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addButton.backgroundColor = .black
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 16
        view.addSubview(addButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)
        ])

    }

    private func setupStubImageVisibility(_ isEmpty: Bool) {
        imageView.isHidden = isEmpty == false
        messageLabel.isHidden = isEmpty == false
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

// MARK: - TableView
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfRowsInSection
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel,
              let category = viewModel.object(at: indexPath) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell

        cell.title.text = category.name
        if indexPath.row != 0 {
            addSeparator(for: cell)
        }

        if indexPath.row == viewModel.numberOfRowsInSection - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        }

        let backgroundView = UIView()
        cell.selectedBackgroundView = backgroundView
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel,
              let category = viewModel.object(at: indexPath) else {
            return
        }

        let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
        cell.checkImageView.isHidden.toggle()

        delegate?.categoryDidSelect(category)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: - CategoryCreation
extension CategoryViewController: NewCategoryViewControllerDelegate {
    func categoryWasCreated(_ category: TrackerCategory) {
        guard let viewModel = viewModel else { return }
        viewModel.add(category)
    }
}

// MARK: - Protocols
protocol CategoryViewControllerDelegate: AnyObject {
    func categoryDidSelect(_ category: TrackerCategory)
}

//extension CategoryViewController: StoreDelegate {
//    func didUpdate() {
//        tableView.reloadData()
//    }
//}
