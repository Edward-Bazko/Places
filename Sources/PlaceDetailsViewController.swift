import Foundation
import UIKit

final class PlaceDetailsViewController: UIViewController {
    private let place: Place
    private var token: Token?
    
    private var imageView: UIImageView!
    private var spinner: UIActivityIndicatorView!
    
    init(place: Place) {
        self.place = place
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        token = NotificationCenter.default.addObserver(descriptor: Place.didChangeNotification, object: place, using: handlePlaceChanged)
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        updateView()
    }
    
    func handlePlaceChanged(_: Place) {
        updateView()
    }
    
    private func updateView() {
        title = place.creationDate.description
        imageView.image = PlacesStore.shared.originalImageAssigned(to: place)
        
//        switch place.state {
//        case .locating:
//            spinner.isHidden = false
//            spinner.startAnimating()
//        case .locatingFailed(_), .done(_), .blank:
//            spinner.isHidden = true
//            spinner.stopAnimating()
//        }
    }
}
