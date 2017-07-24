//
//  Alert.swift
//  SMCoreLib
//
//  Created by Christopher Prince on 7/20/17.
//

import Foundation

public class Alert {
    public static func show(withTitle title:String? = nil, message:String? = nil, allowCancel cancel:Bool = false, okCompletion:(()->())? = nil) {
    
        let window:UIWindow = (UIApplication.shared.delegate?.window)!!
        let vc = window.rootViewController!
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = vc.view!
    
        alert.addAction(UIAlertAction(title: "OK", style: .default) { alert in
            okCompletion?()
        })
        
        if cancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { alert in
            })
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
}
