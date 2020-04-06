import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    private var originalImage: UIImage?
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
        
        
    }
    
    // What happens if I apply a filter multiple times?

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
		// TODO: show the photo picker so we can choose on-device photos
		// UIImagePickerController + Delegate
	}
	
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		// TODO: Save to photo library
	}
	

	// MARK: Slider events
	
	@IBAction func brightnessChanged(_ sender: UISlider) {

	}
	
	@IBAction func contrastChanged(_ sender: Any) {

	}
	
	@IBAction func saturationChanged(_ sender: Any) {

	}
}

