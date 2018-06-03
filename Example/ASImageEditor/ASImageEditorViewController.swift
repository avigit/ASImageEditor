//
//  ASImageEditorViewController.swift
//  ASImageEditor
//
//  Created by Avigit Saha on 6/2/18.
//  Copyright © 2018 Avigit Saha. All rights reserved.
//

import UIKit
import ASImageEditor

class ASImageEditorViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let viewController = ASImageCropperViewController(image: #imageLiteral(resourceName: "cat"))
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
}

extension ASImageEditorViewController: ASImageCropperViewControllerDelegate {
    func imageCropperViewController(_ viewController: ASImageCropperViewController, didCrop image: UIImage?) {
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropperViewControllerDidCancel(_ viewController: ASImageCropperViewController) {
        dismiss(animated: true, completion: nil)
    }
}
