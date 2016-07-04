//
//  ViewController.swift
//  SMImageTextView
//
//  Created by Christopher Prince on 5/21/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

import UIKit
import SMCoreLib

class ViewController: UIViewController {
    @IBOutlet weak var imageTextView: SMImageTextView!
    private var fileURL:NSURL!
    private let fileName = "ImageTextView.json"
    private var acquireImage:SMAcquireImage!
    private var loadedImagesFirstTime = false
    private var addImageBarButton:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageTextView.imageDelegate = self
        
        self.fileURL = FileStorage.urlOfItem(fileName)
        
        self.acquireImage = SMAcquireImage(withParentViewController: self)
        self.acquireImage.delegate = self
        
        self.addImageBarButton = UIBarButtonItem(title: "Add Image", style: .Plain, target: self, action: #selector(addImageAction))
        
        // Uses self.addImageBarButton
        self.makeToolbar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        // Doing this before viewDidAppear doesn't result in proper image scaling. Lovely.
        typealias ITVE = SMImageTextView.ImageTextViewElement
        var initialContents = [ITVE]()
        let text1 = "Hello world\n"
        initialContents.append(.Text(text1, NSMakeRange(0, text1.characters.count)))
        let image1 = UIImage(named: "Cat")
        initialContents.append(.Image(image1, NSUUID(), NSMakeRange(text1.characters.count, 1)))
        self.imageTextView.contents = initialContents
        */
        if !self.loadedImagesFirstTime {
            self.loadedImagesFirstTime = true
            self.imageTextView.loadContents(fromJSONFileURL: self.fileURL)
            Log.msg("Loaded contents from JSON file: \(self.loadedImagesFirstTime)")
        }
    }
    
    private func makeToolbar() {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frameWidth, 50))
        toolbar.barStyle = UIBarStyle.Default
        toolbar.items = [
            self.addImageBarButton,
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Hide", style: .Plain, target: self, action: #selector(hideKeyboardAction))
            ]
        toolbar.sizeToFit()
        self.imageTextView.inputAccessoryView = toolbar
    }
    
    @objc private func addImageAction() {
        self.acquireImage.showAlert(fromBarButton: self.addImageBarButton)
    }
    
    @objc private func hideKeyboardAction() {
        self.imageTextView.resignFirstResponder()
        let success = self.imageTextView.saveContents(toFileURL: self.fileURL)
        Log.msg("Saved contents to JSON file: \(success)")
    }
    
    private func showImageTextViewContents() {
        /*
        if self.imageTextView.contents != nil {
            for elem in self.imageTextView.contents! {
                let dict = elem.toDictionary()
                print("\(dict)")
                let elem2 = SMImageTextView.ImageTextViewElement.fromDictionary(dict)
                print("\(elem2)")
            }
        }*/
    }
}

extension ViewController : SMImageTextViewDelegate {
    func smImageTextView(imageTextView:SMImageTextView, imageDeleted:NSUUID?) {
        Log.msg("UUID of image: \(imageDeleted)")
    }
    
    func smImageTextView(imageTextView: SMImageTextView, imageForUUID: NSUUID) -> UIImage? {
        return UIImage(named: "Cat")
    }
}

extension ViewController : SMAcquireImageDelegate {
    // "Temporary"
    func smAcquireImageURLForNewImage(acquireImage:SMAcquireImage) -> SMRelativeLocalURL {
        return FileExtras().newURLForImage()
    }

    func smAcquireImage(acquireImage:SMAcquireImage, newImageURL: SMRelativeLocalURL) {
        Log.msg("newImageURL \(newImageURL); \(newImageURL.path!)")
        if let image = UIImage(contentsOfFile: newImageURL.path!) {
            self.imageTextView.insertImageAtCursorLocation(image, imageId: NSUUID())
        }
    }
}

