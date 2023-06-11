import UIKit

class TrackerTypeSelectionViewController: UIViewController {

    private var addRegularEvent: UIButton!
    private var addNonregularEvent: UIButton!
    private var titleLabel: UILabel!
    weak var delegate: TrackerAdditionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraits()
    }


    @objc private func addRegularEventDidTap() {
        let vc = RegularEventViewController()
        vc.modalPresentationStyle = .automatic
        vc.delegate = delegate
        present(vc, animated: true)
    }

    @objc private func addNonregularEventDidTap() {
        let vc = NonregularEventViewController()
        vc.modalPresentationStyle = .automatic
        vc.delegate = delegate
        present(vc, animated: true)
    }

}

// MARK: - UI elemets creation
extension TrackerTypeSelectionViewController {
    private func setupViews() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Создание трекера"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(titleLabel)
        addRegularEvent = createButton(title: "Привычка", action: #selector(addRegularEventDidTap))
        view.addSubview(addRegularEvent)
        addNonregularEvent = createButton(title: "Нерегулярное событие", action: #selector(addNonregularEventDidTap))
        view.addSubview(addNonregularEvent)
    }

    private func setupConstraits() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 114),
            addRegularEvent.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addRegularEvent.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addRegularEvent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addRegularEvent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addRegularEvent.heightAnchor.constraint(equalToConstant: 60),
            addNonregularEvent.widthAnchor.constraint(equalToConstant: 60),
            addNonregularEvent.heightAnchor.constraint(equalToConstant: 60),
            addNonregularEvent.leadingAnchor.constraint(equalTo: addRegularEvent.leadingAnchor),
            addNonregularEvent.trailingAnchor.constraint(equalTo: addRegularEvent.trailingAnchor),
            addNonregularEvent.topAnchor.constraint(equalTo: addRegularEvent.bottomAnchor, constant: 16)
        ])
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(named: "black")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
