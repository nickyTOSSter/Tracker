import UIKit

struct CreationManager {
    var name: String = ""
    var category: TrackerCategory?
    var schedule: [WeekDay] = []
    var selectedEmoji: String?
    var selectedColor: UIColor?
    let listItems = ["Категория", "Расписание"]

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
            schedule: schedule
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
            return "Каждый день"
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
