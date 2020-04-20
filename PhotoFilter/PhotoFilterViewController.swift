import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    private var originaImage: UIImage?
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
    
    func filterImage(_ image: UIImage) -> UIImage? {
        
        //Convert the UIImage -> CGImage -> CIImage (CoreImage)
        guard let cgImage = image.cgImage  else { return nil }
        
        //convert image to be a cgImage
        let ciImage = CIImage(cgImage: cgImage)
        
        //initialize filter
        let filter = CIFilter.colorControls()
        filter.inputImage = ciImage
        
        //Sliders confiuguration
        filter.brightness = brightnessSlider.value
        filter.contrast = contrastSlider.value
        filter.saturation = saturationSlider.value
        
        //Unwrap the converted image
        guard let outputCIImage = filter.outputImage else {
            return nil }
        
        //Use our own context for effeciancy to create a CGImage
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        //Revert image back to UIImage to use in the view
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

