import UIKit

// TODO: hide UIImagePickerController as container
final class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didFinish: (UIImage) -> () = { _ in }
    var didCancel: () -> () = { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceType = .camera
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            didFinish(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            didFinish(originalImage)
        } else {
            logError("Failed to pick an image")
            didCancel()
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        didCancel()
    }
}


