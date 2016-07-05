//
//  SMAcquireImage.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 5/22/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

// Let a user acquire images from the camera or other sources.
// Note that this UI interacts with classes such as UITextView. E.g., it will cause the keyboard to be dismissed if present.

import Foundation
import UIKit

public protocol SMAcquireImageDelegate : class {
    // Called before the image is acquired to obtain a URL for the image. A file shouldn't exist at this URL yet.
    func smAcquireImageURLForNewImage(acquireImage:SMAcquireImage) -> SMRelativeLocalURL

    // Called after the image is acquired.
    func smAcquireImage(acquireImage:SMAcquireImage, newImageURL: SMRelativeLocalURL)
}

public class SMAcquireImage : NSObject {
    public weak var delegate:SMAcquireImageDelegate!
    public var acquiringImage:Bool {
        return self._acquiringImage
    }
    
    // This should be a value between 0 and 1, with larger values giving higher quality, but larger files.
    public var compressionQuality:CGFloat = 0.5

    private weak var parentViewController:UIViewController!
    private let imagePicker = UIImagePickerController()
    public var _acquiringImage:Bool = false
    
    // documentsDirectoryPath is the path within the Documents directory to store new image files.
    public init(withParentViewController parentViewController:UIViewController) {
    
        super.init()
        self.parentViewController = parentViewController
        self.imagePicker.delegate = self
    }
    
    public func showAlert(fromBarButton barButton:UIBarButtonItem) {
        self._acquiringImage = true
        
        let alert = UIAlertController(title: "Get an image?", message: nil, preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.barButtonItem = barButton
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { alert in
            self._acquiringImage = false
        })
        
        if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.Camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .Default) { alert in
                self.getImageUsing(.Camera)
            })
        }

        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            alert.addAction(UIAlertAction(title: "Camera Roll", style: .Default) { alert in
                self.getImageUsing(.SavedPhotosAlbum)
            })
        }

        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default) { alert in
                self.getImageUsing(.PhotoLibrary)
            })
        }
        
        self.parentViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func getImageUsing(sourceType:UIImagePickerControllerSourceType) {
        self.imagePicker.sourceType = sourceType
        self.imagePicker.allowsEditing = false

        self.parentViewController.presentViewController(imagePicker, animated: true,
            completion: nil)
    }
}

extension SMAcquireImage : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        Log.msg("info: \(info)")
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Save image to album if you want; also considers video
        // http://www.techotopia.com/index.php/Accessing_the_iOS_8_Camera_and_Photo_Library_in_Swift
        
        let newFileURL = self.delegate?.smAcquireImageURLForNewImage(self)
        Log.msg("newFileURL: \(newFileURL)")
        
        var success:Bool = true
        if let imageData = UIImageJPEGRepresentation(image, self.compressionQuality) {
            do {
                try imageData.writeToURL(newFileURL!, options: .AtomicWrite)
            } catch (let error) {
                Log.error("Error writing file: \(error)")
                success = false
            }
        }
        else {
            Log.error("Couldn't convert image to JPEG!")
            success = false
        }
        
        if success {
            self.delegate.smAcquireImage(self, newImageURL: newFileURL!)
        }
        
        self._acquiringImage = false
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        Log.msg("imagePickerControllerDidCancel")
        
        self._acquiringImage = false
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}