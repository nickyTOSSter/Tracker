import Foundation

//хранит id трекера, который был выполнен и
//дату

struct TrackerRecord: Hashable {
    let id: UUID
    let completionDate: Date
}
