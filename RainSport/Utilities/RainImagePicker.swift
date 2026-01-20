import UIKit

class RainImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var rainOnImageSelected: ((UIImage?) -> Void)?
    
    init(onImageSelected: @escaping (UIImage?) -> Void) {
        self.rainOnImageSelected = onImageSelected
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let rainEditedImage = info[.editedImage] as? UIImage {
            rainOnImageSelected?(rainEditedImage)
        } else if let rainOriginalImage = info[.originalImage] as? UIImage {
            rainOnImageSelected?(rainOriginalImage)
        } else {
            rainOnImageSelected?(nil)
        }
        
        picker.dismiss(animated: true) {
            self.rainOnImageSelected = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.rainOnImageSelected?(nil)
            self.rainOnImageSelected = nil
        }
    }
}

class RainImagePicker {
    static func rainPresentImagePicker(
        sourceType: UIImagePickerController.SourceType,
        from viewController: UIViewController,
        coordinator: inout RainImagePickerCoordinator?,
        onImageSelected: @escaping (UIImage?) -> Void
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            onImageSelected(nil)
            return
        }
        
        let rainPicker = UIImagePickerController()
        rainPicker.sourceType = sourceType
        rainPicker.allowsEditing = true
        
        let rainCoordinator = RainImagePickerCoordinator(onImageSelected: onImageSelected)
        rainPicker.delegate = rainCoordinator
        coordinator = rainCoordinator
        
        viewController.present(rainPicker, animated: true)
    }
}
