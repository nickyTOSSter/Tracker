import UIKit
import CoreData

final class RecordStore: NSObject {
    private let context: NSManagedObjectContext
    private weak var delegate: StoreDelegate?

    private lazy var fetchedResultController: NSFetchedResultsController<RecordCoreData> = {
        let request = RecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "completionDate", ascending: true)]

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

    func add(_ record: TrackerRecord) {
        _ = convert(record: record)
        try! context.save()
    }

    func delete(_ record: TrackerRecord) {
        let datePredicate = NSPredicate(format: "completionDate == %@", record.completionDate as CVarArg)
        let trackerIdPredicate = NSPredicate(format: "trackerId == %@", record.id as CVarArg)

        let request = RecordCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, trackerIdPredicate])

        guard let managedObject = try? context.fetch(request).first else {
            return
        }

        context.delete(managedObject)
        try! context.save()
    }

    func object(by trackerId: UUID, and currentDate: Date) -> TrackerRecord? {
        let datePredicate = NSPredicate(format: "completionDate == %@", currentDate as CVarArg)
        let trackerIdPredicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)

        let request = RecordCoreData.fetchRequest()
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, trackerIdPredicate])

        guard let recordManagedObject = try? context.fetch(request).first else {
            return nil
        }

        return convert(managedObject: recordManagedObject)
    }

    private func convert(record: TrackerRecord) -> RecordCoreData {
        let managedObject = RecordCoreData(context: context)
        managedObject.trackerId = record.id
        managedObject.completionDate = record.completionDate
        return managedObject
    }

    private func convert(managedObject: RecordCoreData) -> TrackerRecord? {
        guard let id = managedObject.trackerId,
            let completionDate = managedObject.completionDate else {
            return nil
        }

        return TrackerRecord(
            id: id,
            completionDate: completionDate
        )
    }

    func amaountOfCompletedTrackers(by trackerId: UUID) -> Int {
        let request = RecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "trackerId == %@", trackerId as CVarArg)

        guard let recordManagedObjects = try? context.fetch(request) else {
            return 0
        }

        return recordManagedObjects.count
    }

}

extension RecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

