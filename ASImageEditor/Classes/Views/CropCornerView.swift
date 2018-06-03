//
//  CropCornerView.swift
//  ImageEditor
//
//  Created by Avigit Saha on 6/1/18.
//  Copyright © 2018 Avigit Saha. All rights reserved.
//

import UIKit

class CropCornerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 16, height: 16)))
        view.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        view.backgroundColor = UIColor(red: 65.0/255.0, green: 105.0 / 255.0, blue: 225.0 / 255.0, alpha: 1)
        view.layer.cornerRadius = view.frame.width / 2
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        addSubview(view)
        
        backgroundColor = UIColor.clear
    }

}
