import Foundation
import CoreLocation

class Place: Hashable {
    
    enum LocationState {
        case blank
        case locating
        case locatingFailed(LocationManagingError)
        case done(CLPlacemark)
    }
    
    var state: LocationState {
        didSet {
            NotificationCenter.default.post(descriptor: Place.didChangeNotification, value: self)
        }
    }
    
    let creationDate: Date
    let uuid: UUID
    
    init(uuid: UUID = UUID(), creationDate: Date = Date()) {
        self.uuid = uuid
        self.creationDate = creationDate
        self.state = .blank
    }
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

extension Place.LocationState: CustomStringConvertible {
    var description: String {
        switch self {
        case .blank:
            return "blank"
        case .done(let placemark):
            return placemark.name ?? placemark.description
        case .locating:
            return "locating..."
        case .locatingFailed(let error):
            return error.localizedDescription
        }
    }
}

extension Place {
    static let didChangeNotification = NotificationDescriptor<Place>(name: .placeDidChangeNotification)
}

private extension Notification.Name {
    static let placeDidChangeNotification = Notification.Name("PlaceDidChangeNotification")
}
