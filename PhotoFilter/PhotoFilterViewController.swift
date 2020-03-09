import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    // Does the app behave differently
    
    // Image
    // 5000x3000 pixels
    // scale the image down to fit in the bounds of the screen
    // 1200x800 pixels (less pixels = less calculations, so it renders faster)
    
    private var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale // 1x 2x 3x

            scaledSize = CGSize(width: scaledSize.width * scale,
                                height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    private let context = CIContext(options: nil)
    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filter = CIFilter.colorControls()
        
        print(filter)
        print(filter.attributes)

        // Use our storyboard placeholder image to start
        originalImage = imageView.image
    }
	
    func filterImage(_ image: UIImage) -> UIImage? {
        
        // UIImage > CGImage > CIImage
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // CIImage > CGImage > UIImage
        
        // Render the image (apply the filter to the image) i.e.: baking cookies in oven
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil // allows us to clear out the image
        }
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: the photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // if completion is nil, what can I do?
        present(imagePicker, animated: true)
    }
    
    
	// MARK: Actions
	
    @IBAction func choosePhotoButtonPressed(_ sender: Any) {
        presentImagePickerController()
    }
	
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		// TODO: Save to photo library
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

extension PhotoFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Picked Image")
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancel")
        
        picker.dismiss(animated: true)
    }
}
