//
//  StackViewTestViewController.swift
//  Chizu
//
//  Created by Nick on 7/24/19.
//  Copyright © 2019 Chizu. All rights reserved.
//

import UIKit

class StackViewTestViewController: UIViewController {
    var stackView: PerspectiveStackView!
    let floors = [UIImage(named: "floor1")!, UIImage(named: "floor2")!, UIImage(named: "floor3")!, UIImage(named: "floor4")!, UIImage(named: "floor5")!]
    
    @IBOutlet weak var done: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    
    var moveNum = 0
    var moveAllNum = 0
    var transformNum = 0
    var transformAllNum = 0
    var spotlightNum = 0
    var views: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        views = makeImageViews()
        
        stackView =  PerspectiveStackView(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: self.view.frame.height)
            , withStackedViews: views, andSpacing: 80)
        //stackView.xOffsetAfterPerspectiveAnimation = 0
        
        self.view.addSubview(stackView)
        stackView.additionalPerspectiveSplayTransforms = [CATransform3DMakeScale(0.63, 0.63, 1)]
        
        view.bringSubviewToFront(done)
        view.bringSubviewToFront(drawButton)
        
        stackView.snp.makeConstraints { (make) in
            make.leftMargin.rightMargin.top.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-100)
        }
    }
    
    func makeImageViews() -> [UIView] {
        return floors.map({
            let image = UIImageView(image: $0.imageRotatedByDegrees(degrees: 90))
            image.contentMode = .scaleAspectFit
            image.frame = self.view.frame.insetBy(dx: 0, dy: 100)
            print(image.layer.transform)
            
            return image
        })
    }
    
    @IBAction func draw(_ sender: Any) {
        
        if Grid.shared.device == nil {
            
            let alert = UIAlertController(title: "\(UIDevice.modelName) isn't yet Supported", message: "This device hasn't had its maps tuned to fit it. Routes may not match up to map properly.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [alert] (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true)
        }
        
//        stackView.drawRoute(forPath: Routes)
//        stackView.drawRoute(forPath: Routes.Example1.allCases[1])
    }
    
    @IBAction func splayAll(_ sender: Any) {
        stackView.perspectiveSplayAllViews()
    }
    
    @IBAction func unsplayAll(_ sender: Any) {
        stackView.undoPerspectiveSplays()
    }
    
    @IBAction func splayOne(_ sender: Any) {
        stackView.moveToSplayedPositionWithPerspective(views[3])
    }
    
    @IBAction func unsplayOne(_ sender: Any) {
        stackView.moveToUnsplayedPositionWithPerspective(views[3])
    }
    
    @IBAction func moveOne(_ sender: Any) {
        isEven(moveNum) ? stackView.moveToSplayedPosition(views[3]) : stackView.moveToUnsplayedPosition(views[3])
        moveNum += 1
    }
    
    @IBAction func moveAll(_ sender: Any) {
        isEven(moveAllNum) ? stackView.splayAllViews() : stackView.unsplayAllViews()
        moveAllNum += 1
    }
    
    @IBAction func transformOne(_ sender: Any) {
        isEven(transformNum) ? stackView.perspectiveShift(view: views[3]) : stackView.undoPerspectiveShift(for: views[3])
        transformNum += 1
    }
    
    @IBAction func transformAll(_ sender: Any) {
        isEven(transformAllNum) ? stackView.perspectiveShiftAllViews() : stackView.undoAllPerspectiveShifts()
        transformAllNum += 1
    }
    
    @IBAction func spotlight(_ sender: Any) {
        isEven(spotlightNum) ? stackView.spotlight(views[1]) : stackView.undoSpotlightAnimation()
        spotlightNum += 1
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func isEven(_ num: Int) -> Bool {
        return (num % 2 == 0)
    }
}



extension UIImage {
    
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
