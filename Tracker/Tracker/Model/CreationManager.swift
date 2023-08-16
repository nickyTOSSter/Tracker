import UIKit

struct CreationManager {
    var name: String = ""
    var category: TrackerCategory?
    var schedule: [WeekDay] = []
    var selectedEmoji: String?
    var selectedColor: UIColor?
    let listItems = [NSLocalizedString("category", comment: "category title"), NSLocalizedString("schedule", comment: "schedule title")]

    let emojies = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝","😪"
    ]

    let colors: [UIColor] = [
        UIColor.sunsetOrange, UIColor.westSide, UIColor.azureRadiance,
        UIColor.electricVioletBlue, UIColor.emerald, UIColor.orchid,
        UIColor.azalea, UIColor.dodgerBlue, UIColor.turquoise,
        UIColor.minsk, UIColor.persimmon, UIColor.carnationPink,
        UIColor.manhattan, UIColor.cornflowerBlue, UIColor.electricViolet,
        UIColor.mediumPurlePink, UIColor.mediumPurle, UIColor.emeraldLight
    ]

    let colorsHex: [String] = [
        ColorMarshall.shared.encode(color: UIColor.sunsetOrange), ColorMarshall.shared.encode(color: UIColor.westSide),
        ColorMarshall.shared.encode(color: UIColor.azureRadiance), ColorMarshall.shared.encode(color: UIColor.electricVioletBlue),
        ColorMarshall.shared.encode(color: UIColor.emerald), ColorMarshall.shared.encode(color: UIColor.orchid),
        ColorMarshall.shared.encode(color: UIColor.azalea), ColorMarshall.shared.encode(color: UIColor.dodgerBlue),
        ColorMarshall.shared.encode(color: UIColor.turquoise), ColorMarshall.shared.encode(color: UIColor.minsk),
        ColorMarshall.shared.encode(color: UIColor.persimmon), ColorMarshall.shared.encode(color: UIColor.carnationPink),
        ColorMarshall.shared.encode(color: UIColor.manhattan), ColorMarshall.shared.encode(color: UIColor.cornflowerBlue),
        ColorMarshall.shared.encode(color: UIColor.electricViolet), ColorMarshall.shared.encode(color: UIColor.mediumPurlePink),
        ColorMarshall.shared.encode(color: UIColor.mediumPurle), ColorMarshall.shared.encode(color: UIColor.emeraldLight)
    ]


    func newTracker() -> Tracker? {
        guard let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            return nil
        }

        return Tracker(
            id: UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: schedule,
            isPinned: false
        )
    }

    func newTracker(id: UUID, isPinned: Bool) -> Tracker? {
        guard let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji else {
            return nil
        }

        return Tracker(
            id: id,
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: schedule,
            isPinned: isPinned
        )
    }


    func isReadyForCreation() -> Bool {
        guard let _ = selectedEmoji,
            let _ = selectedColor,
            let category = category else {
            return false
        }

        return name.isEmpty == false &&
            schedule.isEmpty == false &&
            category.name.isEmpty == false
    }

    func isSchedule(row: Int) -> Bool {
        row == 1
    }

    func getScheduleDescription() -> String {
        var description = ""
        if schedule.count == 7 {
            return NSLocalizedString("everyDay", comment: "String displays when user chose all days in schedule")
        }

        for weekDay in schedule {
            description += weekDay.shortDescription() + ", "
        }

        if description.isEmpty == false {
            description.removeLast(2)
        }

        return description
    }
}
