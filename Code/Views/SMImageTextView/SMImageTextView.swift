//
//  SMImageTextView.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 5/21/16.
//  Copyright © 2016 Spastic Muffin, LLC. All rights reserved.
//

// A text view with images. Deals with keyboard appearing and disappearing by changing the .bottom property of the .contentInset.

import Foundation
import HPTextViewTapGestureRecognizer

@objc public protocol SMImageTextViewDelegate : class {
    optional func smImageTextView(imageTextView:SMImageTextView, imageWasDeleted imageId:NSUUID?)
    
    // You should provide the UIImage corresponding to the NSUUID. Only in an error should this return nil.
    func smImageTextView(imageTextView: SMImageTextView, imageForUUID: NSUUID) -> UIImage?
    
    optional func smImageTextView(imageTextView: SMImageTextView, imageWasTapped imageId:NSUUID?)
}

private class ImageTextAttachment : NSTextAttachment {
    var imageId:NSUUID?
}

public func ==(lhs:SMImageTextView.ImageTextViewElement, rhs:SMImageTextView.ImageTextViewElement) -> Bool {
    return lhs.equals(rhs)
}

public func ===(lhs:SMImageTextView.ImageTextViewElement, rhs:SMImageTextView.ImageTextViewElement) -> Bool {
    return lhs.equalsWithRange(rhs)
}

public class SMImageTextView : UITextView, UITextViewDelegate {
    public weak var imageDelegate:SMImageTextViewDelegate?
    public var scalingFactor:CGFloat = 0.5
    
    override public var delegate: UITextViewDelegate? {
        set {
            if newValue == nil {
                super.delegate = nil
                return
            }
            
            Assert.badMojo(alwaysPrintThisString: "Delegate is setup by SMImageTextView, but you can subclass and declare-- all but shouldChangeTextInRange.")
        }
        
        get {
            return super.delegate
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        super.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        let tapGesture = HPTextViewTapGestureRecognizer()
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /*
    @objc private func imageTapGestureAction() {
        Log.msg("imageTapGestureAction")
    }*/
    
    private var originalEdgeInsets:UIEdgeInsets?
    
    // There are a number of ways to get the text view to play well the keyboard *and* autolayout: http://stackoverflow.com/questions/14140536/resizing-an-uitextview-when-the-keyboard-pops-up-with-auto-layout (see https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html for the idea of changing bottom .contentInset). I didn't use http://stackoverflow.com/questions/12924649/autolayout-constraint-keyboard, but it seems to be another means.
    @objc private func keyboardWillShow(notification:NSNotification) {
        let info = notification.userInfo!
        let kbFrame = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = kbFrame.CGRectValue()
        Log.msg("keyboardFrame: \(keyboardFrame)")
        
        self.originalEdgeInsets = self.contentInset
        var insets = self.contentInset
        insets.bottom += keyboardFrame.size.height
        self.contentInset = insets
    }

    @objc private func keyboardWillHide(notification:NSNotification) {
        self.contentInset = self.originalEdgeInsets!
    }
    
    public func insertImageAtCursorLocation(image:UIImage, imageId:NSUUID?) {
        let attrStringWithImage = self.makeImageAttachment(image, imageId: imageId)
        self.textStorage.insertAttributedString(attrStringWithImage, atIndex: self.selectedRange.location)
    }
    
    private func makeImageAttachment(image:UIImage, imageId:NSUUID?) -> NSAttributedString {
        // Modified from http://stackoverflow.com/questions/24010035/how-to-add-image-and-text-in-uitextview-in-ios

        let textAttachment = ImageTextAttachment()
        textAttachment.imageId = imageId
        
        let oldWidth = image.size.width
        
        //I'm subtracting 10px to make the image display nicely, accounting
        //for the padding inside the textView
        let scaleFactor = oldWidth / (self.frameWidth - 10)
        textAttachment.image = UIImage(CGImage: image.CGImage!, scale: scaleFactor/self.scalingFactor, orientation: image.imageOrientation)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        return attrStringWithImage
    }
    
    private static let ElementType = "ElementType"
    private static let ElementTypeText = "Text"
    private static let ElementTypeImage = "Image"
    private static let RangeLocation = "RangeLocation"
    private static let RangeLength = "RangeLength"
    private static let Contents = "Contents"

    public enum ImageTextViewElement : Equatable {
        case Text(String, NSRange)
        case Image(UIImage?, NSUUID?, NSRange)
        
        public var text:String? {
            switch self {
            case .Text(let string, _):
                return string
                
            case .Image:
                return nil
            }
        }
        
        // Doesn't test range. For text, tests string. For image, tests uuid.
        public func equals(other:SMImageTextView.ImageTextViewElement) -> Bool {
            switch self {
            case .Text(let string, _):
                switch other {
                case .Text(let stringOther, _):
                    return string == stringOther
                case .Image:
                    return false
                }
            
            case .Image(_, let uuid, _):
                switch other {
                case .Image(_, let uuidOther, _):
                    return uuid == uuidOther
                case .Text:
                    return false
                }
            }
        }
        
        public func equalsWithRange(other:SMImageTextView.ImageTextViewElement) -> Bool {
            switch self {
            case .Text(let string, let range):
                switch other {
                case .Text(let stringOther, let rangeOther):
                    return string == stringOther && range.length == rangeOther.length && range.location == rangeOther.location
                case .Image:
                    return false
                }
            
            case .Image(_, let uuid, let range):
                switch other {
                case .Image(_, let uuidOther, let rangeOther):
                    return uuid == uuidOther && range.length == rangeOther.length && range.location == rangeOther.location
                case .Text:
                    return false
                }
            }
        }
        
        public func toDictionary() -> [String:AnyObject] {
            switch self {
            case .Text(let string, let range):
                return [ElementType: ElementTypeText, RangeLocation: range.location, RangeLength: range.length, Contents: string]
            
            case .Image(_, let uuid, let range):
                var uuidString = ""
                if uuid != nil {
                    uuidString = uuid!.UUIDString
                }
                return [ElementType: ElementTypeImage, RangeLocation: range.location, RangeLength: range.length, Contents: uuidString]
            }
        }
        
        // UIImages in .Image elements will be nil.
        public static func fromDictionary(dict:[String:AnyObject]) -> ImageTextViewElement? {
            guard let elementType = dict[ElementType] as? String else {
                Log.error("Couldn't get element type")
                return nil
            }
            
            switch elementType {
            case ElementTypeText:
                guard let rangeLocation = dict[RangeLocation] as? Int,
                    let rangeLength = dict[RangeLength] as? Int,
                    let contents = dict[Contents] as? String
                else {
                    return nil
                }
                
                return .Text(contents, NSMakeRange(rangeLocation, rangeLength))
                
            case ElementTypeImage:
                guard let rangeLocation = dict[RangeLocation] as? Int,
                    let rangeLength = dict[RangeLength] as? Int,
                    let uuidString = dict[Contents] as? String
                else {
                    return nil
                }
                
                return .Image(nil, NSUUID(UUIDString: uuidString), NSMakeRange(rangeLocation, rangeLength))
            
            default:
                return nil
            }
        }
    }
    
    public var contents:[ImageTextViewElement]? {
        get {
            var result = [ImageTextViewElement]()
            
            // See https://stackoverflow.com/questions/37370556/ranges-of-strings-from-nsattributedstring
            
            self.attributedText.enumerateAttributesInRange(NSMakeRange(0, self.attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (dict, range, stop) in
                Log.msg("dict: \(dict); range: \(range)")
                if dict[NSAttachmentAttributeName] == nil {
                    let string = (self.attributedText.string as NSString).substringWithRange(range)
                    Log.msg("string in range: \(range): \(string)")
                    result.append(.Text(string, range))
                }
                else {
                    let imageAttachment = dict[NSAttachmentAttributeName] as! ImageTextAttachment
                    Log.msg("image at range: \(range)")
                    result.append(.Image(imageAttachment.image!, imageAttachment.imageId, range))
                }
            }
            
            Log.msg("overall string: \(self.attributedText.string)")
            
            // TODO: Need to sort each of the elements in the result array by range.location. Not sure if the enumerateAttributesInRange does this for us.
            
            if result.count > 0 {
                return result
            } else {
                return nil
            }
        } // end get
        
        // Any .Image elements must have non-nil images.
        set {
            let mutableAttrString = NSMutableAttributedString()
            
            let currFont = self.font
            
            if newValue != nil {
                for elem in newValue! {
                    switch elem {
                    case .Text(let string, let range):
                        let attrString = NSAttributedString(string: string)
                        mutableAttrString.insertAttributedString(attrString, atIndex: range.location)
                    
                    case .Image(let image, let uuid, let range):
                        let attrImageString = self.makeImageAttachment(image!, imageId: uuid)
                        mutableAttrString.insertAttributedString(attrImageString, atIndex: range.location)
                    }
                }
            }
            
            self.attributedText = mutableAttrString
            
            // Without this, we reset back to a default font size after the insertAttributedString above.
            self.font = currFont
        }
    }
}

// MARK: UITextViewDelegate
extension SMImageTextView {
    // Modified from http://stackoverflow.com/questions/29571682/how-to-detect-deletion-of-image-in-uitextview
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        // empty text means backspace
        if text.isEmpty {
            textView.attributedText.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, textView.attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (object, imageRange, stop) in
            
                if let textAttachment = object as? ImageTextAttachment {
                    if NSLocationInRange(imageRange.location, range) {
                        Log.msg("Deletion of image: \(object); range: \(range)")
                        self.imageDelegate?.smImageTextView?(self, imageWasDeleted: textAttachment.imageId)
                    }
                }
            }
        }

        return true
    }
}

extension SMImageTextView : HPTextViewTapGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, handleTapOnTextAttachment textAttachment: NSTextAttachment!, inRange characterRange: NSRange) {
        let attach = textAttachment as! ImageTextAttachment
        self.imageDelegate?.smImageTextView?(self, imageWasTapped: attach.imageId)
    }
}
