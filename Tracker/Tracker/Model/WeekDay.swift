import Foundation

enum WeekDay: Int {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    static func weekDay(from date: Date) -> WeekDay {
        let weekDayNumber = Calendar.current.component(.weekday, from: date)
        if weekDayNumber == 1 {
            return .sunday
        } else {
            let euWeekDayNumber = weekDayNumber - 1
            return WeekDay(rawValue: euWeekDayNumber)!
        }
    }

    static func encode(weekDays: [WeekDay]) -> String {
        weekDays
            .map({ "\($0.rawValue)" })
            .joined(separator: ", ")
    }

    static func decode(weekDays: String) -> [WeekDay] {
        weekDays
            .components(separatedBy: ", ")
            .compactMap({ Int($0) })
            .compactMap({ WeekDay(rawValue: $0) })
    }

    func description() -> String {
        switch self {
        case .monday:
            return NSLocalizedString("monday", comment: "monday")
        case .tuesday:
            return NSLocalizedString("tuesday", comment: "tuesday")
        case .wednesday:
            return NSLocalizedString("wednesday", comment: "wednesday")
        case .thursday:
            return NSLocalizedString("thursday", comment: "thursday")
        case .friday:
            return NSLocalizedString("friday", comment: "friday")
        case .saturday:
            return NSLocalizedString("saturday", comment: "saturday")
        case .sunday:
            return NSLocalizedString("sunday", comment: "sunday")
        }
    }

    func shortDescription() -> String {
        switch self {
        case .monday:
            return NSLocalizedString("mondayShort", comment: "monday short form")
        case .tuesday:
            return NSLocalizedString("tuesdayShort", comment: "tuesday short form")
        case .wednesday:
            return NSLocalizedString("wednesdayShort", comment: "wednesday short form")
        case .thursday:
            return NSLocalizedString("thursdayShort", comment: "thursday short form")
        case .friday:
            return NSLocalizedString("fridayShort", comment: "friday short form")
        case .saturday:
            return NSLocalizedString("saturdayShort", comment: "saturday short form")
        case .sunday:
            return NSLocalizedString("sundayShort", comment: "sunday short form")
        }

    }

}
