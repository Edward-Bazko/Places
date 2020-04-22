import UIKit

// TODO: hide UIImagePickerController as container
final class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didFinish: (UIImage) -> () = { _ in }
    var didCancel: () -> () = { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
            //cameraCaptureMode = .photo
            allowsEditing = false
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            didFinish(image)
        } else {
            // TODO: something went wrong
            didCancel()
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didCancel()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
