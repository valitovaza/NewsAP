enum NotificationSettingsActions: String {
    case AM10 = "10 AM"
    case PM3 = "3 PM"
    case PM6 = "6 PM"
    case PM7 = "7 PM"
    case PM8 = "8 PM"
    case PM9 = "9 PM"
    case PM10 = "10 PM"
    case Off = "Disable"
    case On = "Enable"
    var time: (hour: Int, min: Int)? {
        switch self {
        case .AM10:
            return (10, 0)
        case .PM3:
            return (15, 0)
        case .PM6:
            return (18, 0)
        case .PM7:
            return (19, 0)
        case .PM8:
            return (20, 0)
        case .PM9:
            return (21, 0)
        case .PM10:
            return (22, 0)
        default:
            return nil
        }
    }
}
