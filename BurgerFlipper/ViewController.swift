//
//  ViewController.swift
//  BurgerFlipper
//
//  Created by Kaan Kabalak on 7/7/17.
//  Copyright © 2017 Kaan Kabalak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var circle: UIView!
    var semiCircleLayer   = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let center = CGPoint (x: circle.frame.size.width / 2, y: circle.frame.size.height / 2)
        let circleRadius = circle.frame.size.width / 2
        let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(0), clockwise: true)
        semiCircleLayer.path = circlePath.cgPath
        semiCircleLayer.fillColor = UIColor.red.cgColor
        semiCircleLayer.lineWidth = 8
        circle.layer.addSublayer(semiCircleLayer)
        
        let angleInRadians: CGFloat = CGFloat(2*Double.pi/3)
        let length: CGFloat = 130
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 1))
        path.close()
//        path.apply(.init(rotationAngle: angleInRadians))
        path.apply(.init(scaleX: length, y: length))
        
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = UIColor.blue.cgColor
        layer.strokeColor = UIColor.blue.cgColor
        layer.lineWidth = 8
        circle.layer.addSublayer(layer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }


}

