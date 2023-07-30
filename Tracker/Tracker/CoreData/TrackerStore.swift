import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private weak var delegate: StoreDelegate?

     private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "category.name", ascending: true)]

        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        fetchedResultController.delegate = self
         
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()

    init(delegate: StoreDelegate) {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.delegate = delegate
    }

    func add(_ tracker: Tracker, to category: TrackerCategory) {
        guard let categoryManagedObject = categoryManagedObject(by: category.id) else {
            return
        }

        let trackerManagedObject = convert(tracker: tracker)
        categoryManagedObject.addToTrackers(trackerManagedObject)
        try! context.save()
    }

    func object(at indexPath: IndexPath) -> Tracker? {
        let managedObject = fetchedResultController.object(at: indexPath)
        return convert(managedObject: managedObject)
    }

    func managedObject(at indexPath: IndexPath) -> TrackerCoreData? {
        let managedObject = fetchedResultController.object(at: indexPath)
        return managedObject
    }

    func isEmpty() -> Bool {
        fetchedResultController.sections?.isEmpty ?? true
    }

    func numberOfSections() -> Int {
        return fetchedResultController.sections?.count ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }

    private func convert(tracker: Tracker) -> TrackerCoreData {
        let managedObject = TrackerCoreData(context: context)
        managedObject.id = tracker.id
        managedObject.name = tracker.name
        managedObject.emoji = tracker.emoji
        managedObject.color = ColorMarshall.shared.encode(color: tracker.color)
        managedObject.schedule = WeekDay.encode(weekDays: tracker.schedule)
        return managedObject
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
            schedule: WeekDay.decode(weekDays: scheduleString)
        )
    }

    private func convert(managedObject: CategoryCoreData) -> TrackerCategory? {
        guard let id = managedObject.id,
            let name = managedObject.name,
            let trackerManagedObjects = managedObject.trackers?.array as? [TrackerCoreData] else {
            return nil
        }

        let trackers: [Tracker] = trackerManagedObjects.compactMap({ convert(managedObject: $0) })
        return TrackerCategory(
            id: id,
            name: name,
            trackers: trackers
        )
    }

    private func categoryManagedObject(by id: UUID) -> CategoryCoreData? {
        let request = CategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }

    func category(at indexPath: IndexPath) -> TrackerCategory? {
        guard let trackerManagedObject = managedObject(at: indexPath),
            let categoryManagedObject = trackerManagedObject.category else {
            return nil
        }

        return convert(managedObject: categoryManagedObject)
    }

    func filter(by date: Date, and searchText: String) {
        var predicates: [NSPredicate] = []
        let weekDay = WeekDay.weekDay(from: date)
        predicates.append(NSPredicate(format: "%K CONTAINS[cd] %@", "schedule", String(weekDay.rawValue)))
        if searchText.isEmpty == false {
            predicates.append(NSPredicate(format: "%K CONTAINS[cd] %@", "name", searchText))
        }
        fetchedResultController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try? fetchedResultController.performFetch()
        delegate?.didUpdate()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
