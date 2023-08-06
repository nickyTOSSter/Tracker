import Foundation

final class CategoryViewModel: StoreDelegate {
    private var categoryStore: CategoryStore?

    @CategoryObservable
    private(set) var categoryIsEmpty: Bool = true

    @CategoryObservable
    private(set) var numberOfRowsInSection: Int = 0


    init() {
        categoryStore = CategoryStore(delegate: self)
    }

    func initialize() {
        guard let categoryStore = categoryStore else { return }
        categoryIsEmpty = categoryStore.isEmpty()
        numberOfRowsInSection = categoryStore.numberOfRowsInSection()
    }

    func add(_ category: TrackerCategory) {
        guard let categoryStore = categoryStore else { return }
        categoryStore.add(category)
    }

    func object(at indexPath: IndexPath) -> TrackerCategory? {
        guard let categoryStore = categoryStore else { return nil }
        return categoryStore.object(at: indexPath)
    }

    func didUpdate() {
        guard let categoryStore = categoryStore else { return }
        numberOfRowsInSection = categoryStore.numberOfRowsInSection()
        categoryIsEmpty = categoryStore.isEmpty()
    }
}


@propertyWrapper
final class CategoryObservable<Value> {
    private var onChange: ((Value) -> Void)? = nil

    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }

    var projectedValue: CategoryObservable<Value> {
        return self
    }

    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    func bind(action: @escaping (Value) -> Void) {
        self.onChange = action
    }
}
