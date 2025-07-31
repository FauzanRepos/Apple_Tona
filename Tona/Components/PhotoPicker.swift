import SwiftUI
import PhotosUI

// ViewModel to store and publish selected images
class SelectedImages: ObservableObject {
    @Published var images: [UIImage] = []
}

// SwiftUI PhotoPicker View
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    var selectionLimit: Int
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = selectionLimit

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.selectedImages.removeAll()
            let itemProviders = results.map { $0.itemProvider }

            for item in itemProviders {
                if item.canLoadObject(ofClass: UIImage.self) {
                    item.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let uiImage = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(uiImage)
                            }
                        }
                    }
                }
            }

            picker.dismiss(animated: true)
        }
    }
}

// Example SwiftUI View using the PhotoPicker
struct ContentView: View {
    @StateObject private var selectedImagesModel = SelectedImages()
    
    var body: some View {
        VStack {
            PhotoPicker(selectedImages: $selectedImagesModel.images, selectionLimit: 8)
                .frame(height: 400)
            
            List(selectedImagesModel.images, id: \ .self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
