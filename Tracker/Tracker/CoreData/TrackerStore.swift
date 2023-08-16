import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private weak var delegate: StoreDelegate?

    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "isPinned == NO")
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

    private lazy var pinnedTrackersFetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "isPinned == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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
        do {
            try context.save()
        } catch {
            print("failed to add tracker")
        }
    }

    func edit(_ tracker: Tracker, to category: TrackerCategory) {
        guard let categoryManagedObject = categoryManagedObject(by: category.id),
            let trackerManagedObject = trackerManagedObject(by: tracker.id) else {
            return
        }

        trackerManagedObject.name = tracker.name
        trackerManagedObject.emoji = tracker.emoji
        trackerManagedObject.color = ColorMarshall.shared.encode(color: tracker.color)
        trackerManagedObject.schedule = WeekDay.encode(weekDays: tracker.schedule)
        trackerManagedObject.isPinned = tracker.isPinned
        trackerManagedObject.category = categoryManagedObject

        do {
            try context.save()
        } catch {
            print("failed to save edited tracker")
        }
    }


    func delete(at indexPath: IndexPath) {

        guard let managedObject = managedObject(at: indexPath), let trackerId = managedObject.id else {
            return
        }

        context.delete(managedObject)
        try! context.save()

        let request = RecordCoreData.fetchRequest()
        request.resultType = .managedObjectResultType
        let trackerIdPredicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [trackerIdPredicate])

        guard let recordObjects = try? context.fetch(request) else {
            return
        }

        for object in recordObjects {
            context.delete(object)
        }

        do {
            try context.save()
        } catch {
            print("failed to delete tracker")
        }
    }

    func toggleTrackerPin(at indexPath: IndexPath) {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            let managedObject = fetchedResultController.object(at: indexPath)
            managedObject.isPinned.toggle()
            do {
                try context.save()
            } catch {
                print("failed to save toggle pin")
            }
            return
        }

        if indexPath.section == 0 {
            let managedObject = pinnedTrackersFetchedResultController.object(at: indexPath)
            managedObject.isPinned.toggle()
        } else {
            let managedObject = fetchedResultController.object(at: IndexPath(item: indexPath.item, section: indexPath.section - 1))
            managedObject.isPinned.toggle()
        }

        do {
            try context.save()
        } catch {
            print("failed to save toggle pin")
        }
    }


    func object(at indexPath: IndexPath) -> Tracker? {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            let managedObject = fetchedResultController.object(at: indexPath)
            return convert(managedObject: managedObject)
        }

        if indexPath.section == 0 {
            let managedObject = pinnedTrackersFetchedResultController.object(at: indexPath)
            return convert(managedObject: managedObject)
        } else {
            let managedObject = fetchedResultController.object(at: IndexPath(item: indexPath.item, section: indexPath.section - 1))
            return convert(managedObject: managedObject)
        }
    }

    func category(at indexPath: IndexPath) -> TrackerCategory? {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            let managedObject = fetchedResultController.object(at: indexPath)
            return convert(managedObject: managedObject.category!)
        }

        if indexPath.section == 0 {
            let managedObject = pinnedTrackersFetchedResultController.object(at: indexPath)
            return convert(managedObject: managedObject.category!)
        } else {
            let managedObject = fetchedResultController.object(at: IndexPath(item: indexPath.item, section: indexPath.section - 1))
            return convert(managedObject: managedObject.category!)
        }
    }


    func managedObject(at indexPath: IndexPath) -> TrackerCoreData? {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultController.object(at: indexPath)
        }

        if indexPath.section == 0 {
            return pinnedTrackersFetchedResultController.object(at: indexPath)
        } else {
            return fetchedResultController.object(at: IndexPath(item: indexPath.item, section: indexPath.section - 1))
        }
    }

    func isEmpty() -> Bool {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, let trackersIsEmpty = fetchedResultController.sections?.isEmpty else {
            return true
        }

        return trackersIsEmpty && pinnedTrackers.isEmpty
    }

    func numberOfSections() -> Int {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultController.sections?.count ?? 0
        }

        return (fetchedResultController.sections?.count ?? 0) + 1
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultController.sections?[section].numberOfObjects ?? 0
        }

        if section == 0 {
            return pinnedTrackers.count
        } else {
            return fetchedResultController.sections?[section - 1].numberOfObjects ?? 0
        }
    }

    private func convert(tracker: Tracker) -> TrackerCoreData {
        let managedObject = TrackerCoreData(context: context)
        managedObject.id = tracker.id
        managedObject.name = tracker.name
        managedObject.emoji = tracker.emoji
        managedObject.color = ColorMarshall.shared.encode(color: tracker.color)
        managedObject.schedule = WeekDay.encode(weekDays: tracker.schedule)
        managedObject.isPinned = tracker.isPinned
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
            schedule: WeekDay.decode(weekDays: scheduleString),
            isPinned: managedObject.isPinned
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

    private func trackerManagedObject(by id: UUID) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try? context.fetch(request).first
    }


    func sectionName(at indexPath: IndexPath) -> String {

        guard let pinnedTrackers = pinnedTrackersFetchedResultController.fetchedObjects, !pinnedTrackers.isEmpty else {
            return fetchedResultController.sections?[indexPath.section].name ?? ""
        }

        if indexPath.section == 0 {
            return "Закрепленные"
        } else {
            return fetchedResultController.sections?[indexPath.section - 1].name ?? ""
        }

    }

    func filter(by date: Date, and searchText: String) {
        var predicates: [NSPredicate] = []
        predicates.append(NSPredicate(format: "isPinned == NO"))
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
