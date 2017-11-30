//
//  FeedbackView.swift
//  Bizintu
//
//  Created by Austin Wei on 11/30/17.
//  Copyright © 2017 Bizintu. All rights reserved.
//

import Foundation
import UIKit

class FeedbackView : UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var checkmark: UIImageView!
    
    @IBOutlet weak var comments: UITextView!
    
    @IBAction func satisfied(_ sender: UIButton) {
        checkmark.isHidden = false
    }
    
    @IBAction func submit(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
