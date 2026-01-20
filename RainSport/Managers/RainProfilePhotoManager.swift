import Combine
import Foundation
import UIKit

class RainProfilePhotoManager: ObservableObject {
    static let shared = RainProfilePhotoManager()
    
    @Published var rainProfilePhoto: UIImage? = nil
    
    private let rainPhotoKey = "rain_profile_photo_v1"
    
    private init() {
        rainLoadPhoto()
    }
    
    func rainSavePhoto(_ image: UIImage) {
        guard let rainImageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        UserDefaults.standard.set(rainImageData, forKey: rainPhotoKey)
        rainProfilePhoto = image
    }
    
    func rainLoadPhoto() {
        guard let rainImageData = UserDefaults.standard.data(forKey: rainPhotoKey),
              let rainImage = UIImage(data: rainImageData) else {
            rainProfilePhoto = nil
            return
        }
        
        rainProfilePhoto = rainImage
    }
    
    func rainDeletePhoto() {
        UserDefaults.standard.removeObject(forKey: rainPhotoKey)
        rainProfilePhoto = nil
    }
}
