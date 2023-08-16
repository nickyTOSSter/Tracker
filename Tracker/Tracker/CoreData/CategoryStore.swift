import UIKit
import CoreData

final class CategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private weak var delegate: StoreDelegate?

    private lazy var fetchedResultsController: NSFetchedResultsController<CategoryCoreData> = {
        let fetchRequest = NSFetchRequest<CategoryCoreData>(entityName: "CategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()

    init(delegate: StoreDelegate) {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.delegate = delegate
    }

    func add(_ category: TrackerCategory) {
        let managedObject = CategoryCoreData(context: context)
        managedObject.id = UUID()
        managedObject.createdAt = Date()
        managedObject.name = category.name
        managedObject.trackers = NSOrderedSet()
        try! context.save()
    }

    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let categoryObj = fetchedResultsController.object(at: indexPath)
        return convert(managedObject: categoryObj)
    }

    func numberOfRowsInSection() -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func isEmpty() -> Bool {
        fetchedResultsController.fetchedObjects?.isEmpty ?? true
    }

    private func convert(managedObject: CategoryCoreData) -> TrackerCategory? {
        guard let id = managedObject.id,
            let name = managedObject.name,
            let trackerManagedObjects = managedObject.trackers?.array as? [TrackerCoreData] else {
            return nil
        }

        let trackers: [Tracker] = trackerManagedObjects.compactMap({
            convert(managedObject: $0)
        })

        return TrackerCategory(
            id: id,
            name: name,
            trackers: trackers
        )
    }

    private func convert(managedObject: TrackerCoreData) -> Tracker? {
        guard let id = managedObject.id,
            let name = managedObject.name,
            let emoji = managedObject.emoji,
            let color = managedObject.color,
            let scheduleString = managedObject.schedule else {
            return nil
        }

        return Tracker(
            id: id,
            name: name,
            color: ColorMarshall.shared.decode(hexColor: color),
            emoji: emoji,
            schedule: WeekDay.decode(weekDays: scheduleString),
            isPinned: managedObject.isPinned
        )
    }
}

extension CategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
