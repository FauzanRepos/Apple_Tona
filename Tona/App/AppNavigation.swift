import SwiftUI

// Central navigation enum for all screens in the app
// Extend with associated data as needed for each screen

enum AppScreen: Hashable {
    case toneGallery
    case uploadPreference
    case toneResult(previewImage: UIImage, toneName: String)
    case uploadPhoto(toneStyle: ToneStyle)
    case adjust(image: UIImage)
    case crop(image: UIImage)
} 