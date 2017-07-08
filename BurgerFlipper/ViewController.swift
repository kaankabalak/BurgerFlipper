//
//  ViewController.swift
//  BurgerFlipper
//
//  Created by Kaan Kabalak on 7/7/17.
//  Copyright © 2017 Kaan Kabalak. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var circle: UIView!
    var semiCircleLayer   = CAShapeLayer()
    
    var motionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // gyroscope
        
        // interval units are in seconds
        motionManager.gyroUpdateInterval = 0.1
        motionManager.deviceMotionUpdateInterval = 0.1
        // each time gyro updates, either return data or error in callback
        motionManager.startGyroUpdates(to: OperationQueue.current!) {(data, error) in
            if let myData = data {
                if myData.rotationRate.x > 6 {
                    print("----------Flick!", myData.rotationRate.x, "-----------")
                }
            }
        }
        
        // each time orientation changes, either return data or error in callback
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) {(data, error) in
            if let myData = data {
                // yaw is initialized to 0 depending on orientation of phone
                // when app launches, start updating orientation
                // when user clicks on 'Play Game', save that yaw orientation in some variable init
                // -90 <= initial_angle <= +90
                // draw semi circle
                let center = CGPoint (x: self.circle.frame.size.width / 2, y: self.circle.frame.size.height / 2)
                let circleRadius = self.circle.frame.size.width / 2
                let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(0), clockwise: true)
                self.semiCircleLayer.path = circlePath.cgPath
                self.semiCircleLayer.fillColor = UIColor.red.cgColor
                self.semiCircleLayer.lineWidth = 8
                self.circle.layer.addSublayer(self.semiCircleLayer)
                
                self.line.layer.sublayers = nil
                
                
                // draw line
                let angleInRadians: CGFloat = CGFloat(-1*myData.attitude.yaw)
                let length: CGFloat = 130
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 1, y: 0))
                path.close()
                path.apply(.init(rotationAngle: angleInRadians))
                path.apply(.init(scaleX: length, y: length))
                
                let layer = CAShapeLayer()
                layer.path = path.cgPath
                layer.fillColor = UIColor.blue.cgColor
                layer.strokeColor = UIColor.blue.cgColor
                layer.lineWidth = 8
                self.line.layer.addSublayer(layer)
                
                self.line.layer.zPosition = 1
                print(self.degrees(myData.attitude.yaw))
            }
        }
    }
    
    func degrees(_ radians: Double) -> Double {
        return 180/Double.pi * radians
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }


}

