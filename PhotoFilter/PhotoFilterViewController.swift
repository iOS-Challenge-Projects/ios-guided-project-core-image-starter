import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class PhotoFilterViewController: UIViewController {

    //MARK: - Properties
    
    private var originalImage: UIImage? {
        didSet{
            
            //Resize image down to make the UI smooth
            //But when we save the image we actually save the original size image
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale //1x (no iphone) 2x 3x
            
            //how many pixel can we fit in the screen
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet{
            updateViews()
        }
    }
    
    private var context = CIContext(options: nil)

    
    //MARK: - Outlets
    
	@IBOutlet weak var brightnessSlider: UISlider!
	@IBOutlet weak var contrastSlider: UISlider!
	@IBOutlet weak var saturationSlider: UISlider!
	@IBOutlet weak var imageView: UIImageView!
	
    //MARK: - View Lifecycle
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        originalImage = imageView.image
	}
    
    
    //MARK: - Custom methods
    
    func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error the photo library is not available.")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func updateViews() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            //Could use a place holder image instead of nil
            imageView.image = nil
        }
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
    
    func savePhotoToLibrary() {
        
        //Unwrap image
        guard let originalImage = originalImage else { return }
        //Pass image to filter original image using our method
        guard let processImage = filterImage(originalImage) else { return }
        
        //Request access
        PHPhotoLibrary.requestAuthorization { (status) in
            
            guard status == .authorized else {
                //Request access.
                //Optional show user how to enable
                //Privacy permission in setting
                //by using a hot link to take user to the settings
                return
            }
            
            //Let library know we are going to make changes
            PHPhotoLibrary.shared().performChanges({
                
                //Make the photo creation request
                PHAssetCreationRequest.creationRequestForAsset(from: processImage)
                
            }) { (sucess, error) in
                //Handle errors
                if let error = error {
                    NSLog("Error saving photo: \(error)")
                }
                
                DispatchQueue.main.async {
                    //We can show a message to user to let them known
                    //INstead of just printing message to developer
                    print("Saved photo")
                }
            }
        }
    }
    
	//MARK: - Actions
	
	@IBAction func choosePhotoButtonPressed(_ sender: Any) {
		// TODO: show the photo picker so we can choose on-device photos
		// UIImagePickerController + Delegate
        presentImagePickerController()
        
	}
	
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		// TODO: Save to photo library
        savePhotoToLibrary()
	}
	

	//MARK: -  Slider events
	
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


//MARK: - UIImagePickerControllerDelegate
extension PhotoFilterViewController: UIImagePickerControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true)
    }
}


//MARK: - UINavigationControllerDelegate

extension PhotoFilterViewController: UINavigationControllerDelegate{

}
