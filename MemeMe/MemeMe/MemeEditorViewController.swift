//
//  MemeEditorViewController.swift
//  MemeMev2.0
//
//  Created by Timothy Ng on 12/17/17.
//  Copyright © 2017 Timothy Ng. All rights reserved.
//

import UIKit

class MemeEditorVC: UIViewController {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var topTextfield: UITextField!
    @IBOutlet weak var bottomTextfield: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIButton!
    
   

    
    let topDefaultText = "TOP"
    let bottomDefaultText = "BOTTOM"
    var memedImage: UIImage?
    let memeTextFormat: [String:Any] = [NSAttributedStringKey.strokeColor.rawValue:UIColor.black, NSAttributedStringKey.foregroundColor.rawValue:UIColor.white, NSAttributedStringKey.font.rawValue:UIFont.init(name: "HelveticaNeue-CondensedBlack", size: 40), NSAttributedStringKey.strokeWidth.rawValue:-3.0]
    var memes = [Meme]()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatText()
        enableShare()
//        enableReset()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        albumButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    

    func formatText() {
        configure(textfield: topTextfield, withText: topDefaultText)
        configure(textfield: bottomTextfield, withText: bottomDefaultText)
    }
    
    func configure(textfield: UITextField, withText: String) {
        textfield.text = withText
        textfield.delegate = self
        textfield.resignFirstResponder()
        textfield.defaultTextAttributes = memeTextFormat
        textfield.textAlignment = .center
    }
    
    func enableShare() {
        shareButton.isEnabled = imagePickerView.image != nil
    }
    
//    func enableReset() {
//        cancelButton.isEnabled = topTextfield.text != topDefaultText || bottomTextfield.text != bottomDefaultText |imagePickerView.image != nil
//    }

   
    @IBAction func pressCancel (_ sender: Any) {
        formatText()
        imagePickerView.image = nil
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
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if bottomTextfield.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification)  -> CGFloat {
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
    
    func generateMemedImge() -> UIImage {
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
    
    func shouldHideBars(_ hide :Bool) {
        toolbar.isHidden = hide
        navigationBar.isHidden = hide
    }
    
    @IBAction func share(_ sender: Any) {
        let memedImage = generateMemedImge()
        let tableViewVC = storyboard?.instantiateViewController(withIdentifier: "SentMemesTableVC") as! SentMemesTableViewController
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
            let meme = Meme(topText: topTextfield.text!, bottomText: bottomTextfield.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
            
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    func checkMemeCreation() -> Bool {
        return topTextfield.text != "" && bottomTextfield.text != "" && imagePickerView.image != nil
    }
}

//MARK: - UITextFieldDelegate, UINavigationControllerDelegate

extension MemeEditorVC: UITextFieldDelegate, UINavigationControllerDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        enableReset()
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

//MARK: - UIImagePickerControllerDelegate

extension MemeEditorVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .scaleAspectFit
//            enableReset()
            enableShare()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

