//
//  ViewController.swift
//  Instafilter
//
//  Created by My Nguyen on 8/11/16.
//  Copyright © 2016 My Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    var currentImage: UIImage!
    // Core Image context, the component that handles rendering
    var context: CIContext!
    // Core Image filter
    var currentFilter: CIFilter!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "YACIFP"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(importPicture))

        context = CIContext(options: nil)
        currentFilter = CIFilter(name: "CISepiaTone")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // see project 10 (NamesToFaces) for a detailed description of the 2 methods:
    // imagePickerController() and imagePickerControllerDidCancel()
    // this method is invoked when an image is imported
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage

        if let possibleImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        dismissViewControllerAnimated(true, completion: nil)

        currentImage = newImage

        // convert from a UIImage to a CIImage
        let beginImage = CIImage(image: currentImage)
        // set the input image of currentFilter to currentImage
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        // do the actual Core Image manipulation
        applyProcessing()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func changeFilter(sender: AnyObject) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
        // add 7 different filters
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .Default, handler: setFilter))
        // and one cancel button
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }

    // the third param is a selector for the callback, which is spelled out for ease of reading
    @IBAction func save(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, "image:didFinishSavingWithError:contextInfo", nil)
    }

    // this method is invoked whenever the slider is moved
    @IBAction func intensityChanged(sender: AnyObject) {
        applyProcessing()
    }

    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }

    func applyProcessing() {
        // not all filters have an intensity setting. so here 4 different input keys are manipulated
        // across 7 different filters: check whether the current filter supports each of the 4 keys,
        // if so, set the value
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(intensity.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            let vector = CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2)
            currentFilter.setValue(vector, forKey: kCIInputCenterKey)
        }

        // create a CGImage from the output image of the current filter. currentFilter.outputImage!.extent means
        // to take all of the image. this is where the actual processing is done
        let cgimg = context.createCGImage(currentFilter.outputImage!, fromRect: currentFilter.outputImage!.extent)
        // convert the CGImage to a UIImage
        let processedImage = UIImage(CGImage: cgimg)
        // set the imageView to the UIImage
        imageView.image = processedImage
    }

    func setFilter(action: UIAlertAction!) {
        // update currentFilter with the chosen filter
        currentFilter = CIFilter(name: action.title!)
        // set the kCIInputImageKey key again, since the filter was just changed
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)

        applyProcessing()
    }

    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let message = "Your altered image has been saved to your photos."
            let ac = UIAlertController(title: "Saved!", message: message, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let message = error?.localizedDescription
            let ac = UIAlertController(title: "Save error", message: message, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
}

