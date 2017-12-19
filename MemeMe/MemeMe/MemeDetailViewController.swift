//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Timothy Ng on 12/17/17.
//  Copyright © 2017 Timothy Ng. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    var meme = Meme(topText: "topText", bottomText: "bottomText", originalImage: UIImage(), memedImage: UIImage())
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeImageView?.image = meme.memedImage
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
   
    
}
