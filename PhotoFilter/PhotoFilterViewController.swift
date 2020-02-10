import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    private var context = CIContext(options: nil)
    
    private var originalImage: UIImage? {
        didSet {

            // scale down the image

            guard let originalImage = originalImage else { return }

            // Height and width
            var scaledSize = imageView.bounds.size

            // 1x, 2x, or 3x
            let scale = UIScreen.main.scale

            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            print("size: \(scaledSize)")
            
            // Update the display with the scaled image
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }

    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        print("Bounds: \(UIScreen.main.bounds)")
        print("Scale: \(UIScreen.main.scale)")
        
//        let filter = CIFilter.colorControls() // Like a recipe
//        print(filter)
//        print(filter.attributes)
        
        originalImage = imageView.image
	}
    
    func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil // reseting image to nothing
        }
    }

    func filterImage(_ image: UIImage) -> UIImage? {
        print("filter")
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.colorControls() // Like a recipe

        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        // CIImage -> CGImage -> UIImage
        guard let outputCIImage = filter.outputImage else { return nil }

        // Rendering the image (actually baking the cookies)
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func showImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available")
            return
        }        
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    
	// MARK: Actions
	
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        showImagePicker()
    }
	
    @IBAction func savePhotoButtonPressed(_ sender: UIButton) {
        
        guard let originalImage = originalImage else { return }
        guard let processedImage = filterImage(originalImage.flattened) else { return }

        PHPhotoLibrary.requestAuthorization { (status) in

            guard status == .authorized else { fatalError("User did not authorize app to save photos") }

            // Let the library know we are going to make changes
            PHPhotoLibrary.shared().performChanges({

                // Make a new photo creation request
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)

            }, completionHandler: { (success, error) in
                if let error = error {
                    print("Error saving photo: \(error)")
                    return
                }

                DispatchQueue.main.async {
                    print("Saved image!")
                }
            })
        }
    }
	

	// MARK: Slider events
	
    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func contrastChanged(_ sender: Any) {
        updateImage()
    }

    @IBAction func saturationChanged(_ sender: Any) {
        updateImage()
    }
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension PhotoFilterViewController: UINavigationControllerDelegate {
    
}
