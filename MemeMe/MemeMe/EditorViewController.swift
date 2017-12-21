//
//  EditorTestViewController.swift
//  MemeMe
//
//  Created by Timothy Ng on 12/20/17.
//  Copyright © 2017 Timothy Ng. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    let topDefaultText = "TOP"
    let bottomDefaultText = "BOTTOM"
    let memeTextFormat: [String:Any] = [NSAttributedStringKey.strokeColor.rawValue:UIColor.black,
                                        NSAttributedStringKey.foregroundColor.rawValue:UIColor.white,
                                        NSAttributedStringKey.font.rawValue:UIFont.init(name:"HelveticaNeue-CondensedBlack", size: 40),
         NSAttributedStringKey.strokeWidth.rawValue:-3.0]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatText()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        albumButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        enableShare()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    func formatText() {
        configure(textfield: topTextField, withText: topDefaultText)
        configure(textfield: bottomTextField, withText: bottomDefaultText)
    }
    
    func configure(textfield: UITextField, withText: String) {
        textfield.text = withText
        textfield.delegate = self
        textfield.resignFirstResponder()
        textfield.defaultTextAttributes = memeTextFormat
        textfield.textAlignment = .center
    }
    
    func enableShare() {
        shareButton.isEnabled = memeImageView.image != nil
    }
    
    @IBAction func pressCancel(_ sender: Any) {
        formatText()
        memeImageView.image = nil
        cancelButton.isEnabled = false
        shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
       chooseSourceType(sourceType: .camera)
    }

    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        chooseSourceType(sourceType: .photoLibrary)
    }
    
    func chooseSourceType(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func generateMemedImage() -> UIImage {
     
        // TODO: Hide toolbar and navbar
        
        shouldHideBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        
        shouldHideBars(false)
        
        return memedImage
    }
    
    func shouldHideBars(_ hide: Bool) {
        navigationBar.isHidden = hide
        toolbar.isHidden = hide
    }
    
    @IBAction func share(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed == true {
                self.save(memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityController, animated: true, completion: nil)
    }
    
    func save(_ memedImage: UIImage) {
        if checkMemeCreation() {
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImageView.image!, memedImage: memedImage)
            
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    func checkMemeCreation() -> Bool {
        return topTextField.text != "" && bottomTextField.text != "" && memeImageView.image != nil
    }
}

//MARK: - UITextFieldDelegate, UINavigationControllerDelegate

extension EditorViewController: UITextFieldDelegate, UINavigationControllerDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enableShare()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text == "" {
            switch textField.tag {
            case 0:
                textField.text = topDefaultText
            case 1:
                textField.text = bottomDefaultText
            default:
                return true
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}

extension EditorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            memeImageView.image = image
            memeImageView.contentMode = .scaleAspectFit
            enableShare()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
