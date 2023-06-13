import Foundation
import UIKit

//создан Tracker — сущность для хранения информации про трекер (для «Привычки» или «Нерегулярного события»).
//У него есть
//уникальный идентификатор (id),
//название,
//цвет,
//эмоджи
//и распиcание.
//Структуру данных для хранения расписания выберите на своё усмотрение;

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay: Bool]

    init(name: String, color: UIColor, emoji: String, schedule: [WeekDay: Bool]) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
