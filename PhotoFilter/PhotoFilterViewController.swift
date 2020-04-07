import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    private var originalImage: UIImage? {
        didSet {
            // resize a scaledImage any time this property is set, so that the UI can update
            // faster with a "live preview"
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale // 1x (no iPhones) 2x 3x
            
            // Debug statements, take these out for your final submissions
            print("image size: \(originalImage.size)")
            print("size: \(scaledSize)")
            print("scale: \(scale)")
            
            // how many pixels can we fit on the screen?
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    private var context = CIContext(options: nil)
    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        let filter = CIFilter.colorControls()
        print(filter)
        
        print(filter.attributes)
        
        // Test the filter quickly
        originalImage = imageView.image
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // What happens if I apply a filter multiple times?

    // Why is this slower?
    
    // Where should I call update views?
    // sliders
    // didSet
    
    func updateViews() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil // placeholder image
        }
    }
    
    func filterImage(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage (Core Graphics) -> CIImage (Core Image)
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Filter = recipe
        let filter = CIFilter.colorControls()
        
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else {
                                                            return nil
        }
        
        // CIImage -> CGImage -> UIImage
        return UIImage(cgImage: outputCGImage)
    }
	
	// MARK: Actions
	
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        presentImagePickerController()
    }
	
@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
    guard let originalImage = originalImage else { return }
    
    guard let processedImage = filterImage(originalImage.flattened) else { return } // flatten/orientation
    
    PHPhotoLibrary.requestAuthorization { (status) in
        
        guard status == .authorized else {
            // request access, show the User how to enable Privacy Permission in Settings
            return
        }
        
        // Let the library know we are going to make changes
        PHPhotoLibrary.shared().performChanges({
            
            // Make a new photo creation request
            
            PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
            
        }, completionHandler: { (success, error) in
            
            if let error = error {
                NSLog("Error saving photo: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                print("Saved Photo")
            }
        })
    }
}
	

	// MARK: Slider events
	
	@IBAction func brightnessChanged(_ sender: UISlider) {
        updateViews()
	}
	
	@IBAction func contrastChanged(_ sender: Any) {
        updateViews()
	}
	
	@IBAction func saturationChanged(_ sender: Any) {
        updateViews()
	}
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {

    // What do I want to do when we finish picking?
    
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
