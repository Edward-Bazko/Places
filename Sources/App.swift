import UIKit

final class App {
    let application: UIApplication
    let window: UIWindow
    var navigationController: UINavigationController!

    let store = PlacesStore.shared
    let placesController: PlacesController
    let locationManager = LocationManager()
    
    init(application: UIApplication, window: UIWindow) {
        self.application = application
        self.window = window
        
        placesController = PlacesController()
        
        navigationController = makeMyPlacesNavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func makeMyPlacesNavigationController() -> UINavigationController {
        let places = PlacesTableViewController(store: store)
        let nc = UINavigationController(rootViewController: places)
        places.didSelect = { [unowned self, unowned nc] place in
            nc.show(PlaceDetailsViewController(place: place), sender: self)
        }
        
        places.navigationItem.leftItemsSupplementBackButton = true
        places.navigationItem.leftBarButtonItem = places.editButtonItem
        places.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCameraImagePicker))
        return nc
    }
    
    @objc func showCameraImagePicker() {
        let picker = ImagePickerController()
        picker.didFinish = { [unowned self, unowned picker] image in
            picker.dismiss(animated: true, completion: {
                let place = self.placesController.importPlaceFromPhoto(image)
                let details = PlaceDetailsViewController(place: place)
                self.navigationController.show(details, sender: self)
            })
        }
        picker.didCancel = { [unowned picker] in
            picker.dismiss(animated: true, completion: nil)
        }
        navigationController.present(picker, animated: true, completion: nil)
    }
    
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""),
                                      message: NSLocalizedString(message, comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        navigationController.present(alert, animated: true, completion: nil)
    }
}
