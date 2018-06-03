//
//  ASImageCropperViewController.swift
//  ImageEditor
//
//  Created by Avigit Saha on 5/24/18.
//  Copyright © 2018 Avigit Saha. All rights reserved.
//

import UIKit
import AVFoundation

public protocol ASImageCropperViewControllerDelegate: NSObjectProtocol {
    func imageCropperViewController(_ viewController: ASImageCropperViewController, didCrop image: UIImage?)
    func imageCropperViewControllerDidCancel(_ viewController: ASImageCropperViewController)
}

public class ASImageCropperViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cropAreaView: UIView!
    @IBOutlet weak var corner1: CropCornerView!
    @IBOutlet weak var corner2: CropCornerView!
    @IBOutlet weak var corner3: CropCornerView!
    @IBOutlet weak var corner4: CropCornerView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    private(set) var image: UIImage
    
    public weak var delegate: ASImageCropperViewControllerDelegate?
    
    private var overlay = CAShapeLayer()
    private var initialCenter = CGPoint()
    private var imageAspectRectOnView = CGRect.zero
    
    private let minimumCroppingSize = CGSize(width: 50, height: 50)
    
    public init(image: UIImage) {
        self.image = image
        let bundle = Bundle(for: ASImageCropperViewController.self)
        super.init(nibName: "ASImageCropperViewController", bundle: bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.image = UIImage()
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        modalPresentationStyle = .overCurrentContext
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        overlay.frame = view.bounds
        showCropOverlay()
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    private func aspectFitSize(of image: UIImage, in rect: CGRect) -> CGSize {
        let ratio = image.size.width / image.size.height
        
        if image.size.width > image.size.height {
            var width = rect.width
            var height = width / ratio
            
            if height > rect.height {
                height = rect.height
                width = height * ratio
            }
            
            return CGSize(width: width, height: height)
        } else {
            var height = rect.height
            var width = height * ratio
            
            if width > rect.width {
                width = rect.width
                height = width / ratio
            }
            
            return CGSize(width: width, height: height)
        }
    }
    
    private func showCropOverlay() {
        guard overlay.superlayer == nil, let image = imageView.image else {
            return
        }
        
        let padding: CGFloat = 1
        var aspectSize = aspectFitSize(of: image, in: imageView.frame)
        aspectSize.height += padding * 2
        aspectSize.width += padding * 2
        let imageViewOriginOnView = imageView.convert(imageView.frame.origin, to: view)
        let origin = CGPoint(x: imageViewOriginOnView.x - padding, y: imageViewOriginOnView.y - padding + (imageView.frame.height - aspectSize.height) / 2)
        
        cropAreaView.frame = CGRect(origin: origin, size: aspectSize)
        cropAreaView.layer.borderColor = UIColor.white.cgColor
        cropAreaView.layer.borderWidth = padding
        
        imageAspectRectOnView = cropAreaView.frame
        
        corner1.center = cropAreaView.frame.origin
        corner2.center = CGPoint(x: cropAreaView.frame.maxX, y: cropAreaView.frame.minY)
        corner3.center = CGPoint(x: cropAreaView.frame.minX, y: cropAreaView.frame.maxY)
        corner4.center = CGPoint(x: cropAreaView.frame.maxX, y: cropAreaView.frame.maxY)
        
        let fillPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 0)
        let cropPath = UIBezierPath(roundedRect: cropAreaView.frame, cornerRadius: 0)
        fillPath.append(cropPath)
        fillPath.usesEvenOddFillRule = true
        
        overlay.path = fillPath.cgPath
        overlay.fillRule = kCAFillRuleEvenOdd
        overlay.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        view.layer.addSublayer(overlay)
        
        bringCornersToFront()
        view.bringSubview(toFront: toolBar)
        
        animateCroppingArea()
    }
    
    private func animateCroppingArea() {
        UIView.animate(withDuration: 0.25) {
            let alpha: CGFloat = 1
            self.cropAreaView.alpha = alpha
            self.corner1.alpha = alpha
            self.corner2.alpha = alpha
            self.corner3.alpha = alpha
            self.corner4.alpha = alpha
        }
    }
    
    private func updateOverlay() {
        cropAreaView.frame = CGRect(origin: corner1.center, size: CGSize(width: corner2.center.x - corner1.center.x, height: corner3.center.y - corner1.center.y))
        
        let shapeLayer = CAShapeLayer()
        let fillPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: 0)
        let cropPath = UIBezierPath(roundedRect: cropAreaView.frame, cornerRadius: 0)
        fillPath.append(cropPath)
        fillPath.usesEvenOddFillRule = true
        
        shapeLayer.path = fillPath.cgPath
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        shapeLayer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        overlay.removeFromSuperlayer()
        overlay = shapeLayer
        view.layer.addSublayer(overlay)
        bringCornersToFront()
        view.bringSubview(toFront: toolBar)
    }
    
    private func bringCornersToFront() {
        view.bringSubview(toFront: corner1)
        view.bringSubview(toFront: corner2)
        view.bringSubview(toFront: corner3)
        view.bringSubview(toFront: corner4)
    }
    
    @IBAction func corner1DragAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        
        let translation = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .began:
            initialCenter = corner1.center
            
        case .changed:
            var newCenter = CGPoint(x: max(imageAspectRectOnView.origin.x, initialCenter.x + translation.x), y: max(imageAspectRectOnView.origin.y, initialCenter.y + translation.y))
            
            // check minimum distance with adjacent corners
            if corner2.center.x - newCenter.x < minimumCroppingSize.width {
                newCenter.x = corner2.center.x - minimumCroppingSize.width
            }
            
            if corner3.center.y - newCenter.y < minimumCroppingSize.height {
                newCenter.y = corner3.center.y - minimumCroppingSize.height
            }
            
            corner1.center = newCenter
            
            // update adjacent corners
            corner2.center = CGPoint(x: corner2.center.x, y: newCenter.y)
            corner3.center = CGPoint(x: newCenter.x, y: corner3.center.y)
            updateOverlay()
            
        default:
            break
        }
    }
    
    @IBAction func corner2DragAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .began:
            initialCenter = corner2.center
            
        case .changed:
            var newCenter = CGPoint(x: min(imageAspectRectOnView.maxX, initialCenter.x + translation.x), y: max(imageAspectRectOnView.origin.y, initialCenter.y + translation.y))
             
            // check minimum distance with adjacent corners
            if newCenter.x - corner1.center.x < minimumCroppingSize.width {
                newCenter.x = corner1.center.x + minimumCroppingSize.width
            }
            
            if corner4.center.y - newCenter.y < minimumCroppingSize.height {
                newCenter.y = corner4.center.y - minimumCroppingSize.height
            }
            
            corner2.center = newCenter
            
            // update adjacent corners
            corner1.center = CGPoint(x: corner1.center.x, y: newCenter.y)
            corner4.center = CGPoint(x: newCenter.x, y: corner4.center.y)
            updateOverlay()
            
        default:
            break
        }
    }
    
    @IBAction func corner3DragAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .began:
            initialCenter = corner3.center
            
        case .changed:
            var newCenter = CGPoint(x: max(imageAspectRectOnView.origin.x, initialCenter.x + translation.x), y: min(imageAspectRectOnView.maxY, initialCenter.y + translation.y))
            
            // check minimum distance with adjacent corners
            if corner4.center.x - newCenter.x < minimumCroppingSize.width {
                newCenter.x = corner4.center.x - minimumCroppingSize.width
            }
            
            if newCenter.y - corner1.center.y < minimumCroppingSize.height {
                newCenter.y = corner1.center.y + minimumCroppingSize.height
            }
            
            corner3.center = newCenter
            
            // update adjacent corners
            corner1.center = CGPoint(x: newCenter.x, y: corner1.center.y)
            corner4.center = CGPoint(x: corner4.center.x, y: newCenter.y)
            updateOverlay()
            
        default:
            break
        }
    }
    
    @IBAction func corner4DragAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else {return}
        
        let translation = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .began:
            initialCenter = corner4.center
            
        case .changed:
            var newCenter = CGPoint(x: min(imageAspectRectOnView.maxX, initialCenter.x + translation.x), y: min(imageAspectRectOnView.maxY, initialCenter.y + translation.y))
            
            // check minimum distance with adjacent corners
            if newCenter.x - corner3.center.x < minimumCroppingSize.width {
                newCenter.x = corner3.center.x + minimumCroppingSize.width
            }
            
            if newCenter.y - corner2.center.y < minimumCroppingSize.height {
                newCenter.y = corner2.center.y + minimumCroppingSize.height
            }
            
            corner4.center = newCenter
            
            // update adjacent corners
            corner2.center = CGPoint(x: newCenter.x, y: corner2.center.y)
            corner3.center = CGPoint(x: corner3.center.x, y: newCenter.y)
            updateOverlay()
            
        default:
            break
        }
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
        let widthScale = image.size.width / imageAspectRectOnView.width
        let heightScale = image.size.height / imageAspectRectOnView.height
        
        let cropZone = CGRect(x: (cropAreaView.frame.minX - imageAspectRectOnView.minX) * widthScale,
                              y: (cropAreaView.frame.minY - imageAspectRectOnView.minY) * heightScale,
                              width: cropAreaView.frame.width * widthScale,
                              height: cropAreaView.frame.height * heightScale
        )
        
        let croppedImage = image.croppedImage(to: cropZone)
        delegate?.imageCropperViewController(self, didCrop: croppedImage)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        delegate?.imageCropperViewControllerDidCancel(self)
    }
}

extension ASImageCropperViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

