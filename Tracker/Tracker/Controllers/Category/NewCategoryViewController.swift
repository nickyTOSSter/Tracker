import UIKit

class NewCategoryViewController: UIViewController {
    private var titleLabel: UILabel!
    private var inputContainer: UIView!
    private var nameTextField: UITextField!
    private var createButton: UIButton!

    weak var delegate: NewCategoryViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
        setCreationButtonAccessibility()
    }

    @objc private func createButtonTapped() {
        guard let categoryName = nameTextField.text else {
            return
        }

        let newCategory = TrackerCategory(id: UUID(), name: categoryName, trackers: [])
        delegate?.categoryWasCreated(newCategory)
        dismiss(animated: true)
    }

    private func setCreationButtonAccessibility() {
        if nameTextField.text?.isEmpty == false {
            createButton.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
            createButton.isEnabled = false
        }

    }
}

// MARK: - Textfield
extension NewCategoryViewController: UITextFieldDelegate {
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

// MARK: - UI
extension NewCategoryViewController {
    private func setupViews() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = NSLocalizedString("category.new.title", comment: "Category creation view controller title")
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)

        inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor(red: 0.9, green: 0.91, blue: 0.92, alpha: 0.3)
        inputContainer.layer.masksToBounds = true
        inputContainer.layer.cornerRadius = 16


        nameTextField = UITextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.placeholder = NSLocalizedString("category.new.placeholder", comment: "Category name textfield placeholder")
        nameTextField.clearButtonMode = .whileEditing
        nameTextField.delegate = self
        nameTextField.returnKeyType = .done
        nameTextField.enablesReturnKeyAutomatically = true
        inputContainer.addSubview(nameTextField)
        view.addSubview(inputContainer)


        createButton = UIButton()
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setTitle(NSLocalizedString("done", comment: "Done button title"), for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.backgroundColor = .black
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        view.addSubview(createButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 22),
            inputContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            inputContainer.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])

    }

}

// MARK: - Protocol
protocol NewCategoryViewControllerDelegate: AnyObject {
    func categoryWasCreated(_ category: TrackerCategory)
}
