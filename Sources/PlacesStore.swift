import Foundation
import UIKit

protocol PlaceStoring {
    func add(_ place: Place)
    func remove(_ place: Place)
    var places: [Place] { get }
    
    func assign(_ originalImage: UIImage, to place: Place)
    func originalImageAssigned(to place: Place) -> UIImage?
    func thumbnailImageAssigned(to place: Place) -> UIImage?
}

class PlacesStore: PlaceStoring {
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    private let notificationCenter = NotificationCenter.default
    private var token: Token?
    var places: [Place] = []
    let baseURL: URL
    
    init(url: URL) {
        baseURL = url
        
        token = notificationCenter.addObserver(descriptor: Place.didChangeNotification) { [weak self] place in
            guard let strongSelf = self else { return }
            guard let index = strongSelf.places.firstIndex(of: place) else { return }
            let payload = PlacesStoreChangePayload(change: .update(index: index, place: place), store: strongSelf)
            strongSelf.notificationCenter.post(descriptor: PlacesStore.didChangeNotification, value: payload)
        }
    }
    
    func add(_ place: Place) {
        places.append(place)
        places.sort(by: { $0.creationDate < $1.creationDate })        
        let newIndex = places.firstIndex(of: place)!
        save(place, payload: PlacesStoreChangePayload(change: .add(index: newIndex), store: self))
    }
    
    func remove(_ place: Place) {
        guard let index = places.firstIndex(of: place) else { return }
        places.remove(at: index)
        deleteImageFile(for: place)
        save(place, payload: PlacesStoreChangePayload(change: .remove(index: index), store: self))
    }
    
    func assign(_ originalImage: UIImage, to place: Place) {
        save(originalImage: originalImage, to: place)
        save(thumbnailFrom: originalImage, to: place)
        
        guard let index = places.firstIndex(of: place) else { return }
        let payload = PlacesStoreChangePayload(change: .update(index: index, place: place), store: self)
        notificationCenter.post(descriptor: PlacesStore.didChangeNotification, value: payload)
        notificationCenter.post(descriptor: Place.didChangeNotification, value: place)
    }
    
    private func save(originalImage: UIImage, to place: Place) {
        guard let data = originalImage.jpegData(compressionQuality: 1) else { return }
        do {
            try data.write(to: originalImageFileURL(for: place), options: .atomic)
        } catch let error {
            print("Failed to save image \(error)")
        }
    }
    
    private func save(thumbnailFrom originalImage: UIImage, to place: Place) {
        guard let thumb = makeThumbnailFrom(image: originalImage),
            let thumbData = thumb.pngData() else { return }
        do {
            try thumbData.write(to: thumbnailImageFileURL(for: place), options: .atomic)
        } catch let error {
            print("Failed to save image \(error)")
        }
    }
    
    func originalImageAssigned(to place: Place) -> UIImage? {
        let url = originalImageFileURL(for: place)
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        return UIImage(data: data)
    }
    
    func thumbnailImageAssigned(to place: Place) -> UIImage? {
        let url = thumbnailImageFileURL(for: place)
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
        return UIImage(data: data)
    }
    
    fileprivate func save(_ notifying: Place, payload: PlacesStoreChangePayload) {
        notificationCenter.post(descriptor: PlacesStore.didChangeNotification, value: payload)
    }
    
    fileprivate func deleteImageFile(for place: Place) {
        let url = originalImageFileURL(for: place)
        try? FileManager.default.removeItem(at: url)
    }
    
    fileprivate func makeThumbnailFrom(image: UIImage) -> UIImage? {
        guard let imageData = image.pngData() else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 100] as CFDictionary
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
            let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        let thumbnail = UIImage(cgImage: imageReference)
        return thumbnail
    }
    
    fileprivate func originalImageFileURL(for place: Place) -> URL {
        return baseURL.appendingPathComponent(place.uuid.uuidString + ".jpg")
    }
    
    fileprivate func thumbnailImageFileURL(for place: Place) -> URL {
        return baseURL.appendingPathComponent(place.uuid.uuidString + "-thumb" + ".png")
    }
}

extension PlacesStore {
    static let shared = PlacesStore(url: documentDirectory)
    static let didChangeNotification = NotificationDescriptor<PlacesStoreChangePayload>(name: .storeDidChangeNotification)
}

struct PlacesStoreChangePayload {
    enum Change {
        case add(index: Int)
        case remove(index: Int)
        case update(index: Int, place: Place) // TODO: state update?
    }
    let change: Change
    let store: PlaceStoring
}

private extension Notification.Name {
    static let storeDidChangeNotification = Notification.Name("PlacesStoreDidChangeNotification")
}
