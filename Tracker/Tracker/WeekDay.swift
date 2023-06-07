import Foundation

enum WeekDay: Int {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    func description() -> String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }

    func shortDescription() -> String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }

    }

    static func scheduleTemplate() -> [WeekDay: Bool] {
        [
            .monday: false, .tuesday: false,
            .wednesday: false, .thursday: false,
            .friday: false, .saturday: false,
            .sunday: false
        ]
    }

    static func weekDay(from date: Date) -> WeekDay {
        let weekDayNumber = Calendar.current.component(.weekday, from: date)
        if weekDayNumber == 1 {
            return .sunday
        } else {
            let euWeekDayNumber = weekDayNumber - 1
            return WeekDay(rawValue: euWeekDayNumber)!
        }
    }
}
