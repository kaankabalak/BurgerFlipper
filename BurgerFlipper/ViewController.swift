//
//  ViewController.swift
//  BurgerFlipper
//
//  Created by Kaan Kabalak on 7/7/17.
//  Copyright © 2017 Kaan Kabalak. All rights reserved.
//
import AVFoundation
import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var circleCopy: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timer: KDCircularProgress!
    
    var score = 0
    
    var semiCircleLayer   = CAShapeLayer()
    var pattyLayer   = CAShapeLayer()
    var motionManager = CMMotionManager()
    
    var pattyAngle = CGFloat(Double.pi/2)
    
    var seconds = 600
    var timeDisplay : Timer?
    
    var isGameStarted : Bool = false
    var isMusicPlaying: Bool = false
    var audioPlayer = AVAudioPlayer()
    var flip = AVAudioPlayer()
    
    @IBAction func playAgainPressed(_ sender: UIButton) {
        isGameStarted = true
        self.seconds = 600
        self.viewDidLoad()
        timer.angle = 180
        score = 0
        scoreLabel.text = String(score)
    }
    
    func playBGM() {
        do {
            if !self.isMusicPlaying {
                audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "bgm", ofType: "mp3")!))
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 0.1
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
                self.isMusicPlaying = true
            }
        }
        catch {
            print(error)
        }
    }
    
    func playFlipSound() {
        do {
            flip = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "flip", ofType: "wav")!))
            flip.prepareToPlay()
            flip.play()
        }
        catch {
            print(error)
        }
    }
    
    func runTimer() {
        timeDisplay = Timer.scheduledTimer(timeInterval: 1.0/30, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if seconds > 1 {
            seconds -= 1
            timer.angle -= 180/600
        }
        else {
            timer.angle = 0
            seconds = 0
            self.line.layer.sublayers = nil
            playAgainButton.isHidden = false
            timeDisplay?.invalidate()
            timeDisplay = nil
            motionManager.stopDeviceMotionUpdates()
        }
        
    }

    
    override func viewDidLoad() {
        playBGM()
        playAgainButton.layer.cornerRadius = 10
        if (isGameStarted == true){
            playAgainButton.setTitle("Play again", for: .normal)
            playAgainButton.isHidden = true
            self.runTimer()
            self.timer.layer.zPosition = 1
            scoreLabel.text = String(score)
            super.viewDidLoad()
            self.drawPatty()
            var angle = CGFloat(Double.pi/2)
          
            // Do any additional setup after loading the view, typically from a nib.
            
            // gyroscope
            
            // interval units are in seconds
            motionManager.gyroUpdateInterval = (0.05)
            motionManager.deviceMotionUpdateInterval = (1.0/60.0)
            // each time gyro updates, either return data or error in callback
            motionManager.startGyroUpdates(to: OperationQueue.current!) {(data, error) in
                if let myData = data {
                    if (self.seconds > 0) {
                        if myData.rotationRate.x > 1.75 {
                            if(abs(angle-self.pattyAngle) < 0.15){
                                self.playFlipSound()
                                print("SUCCESS--------", myData.rotationRate.x, "-----------")
                                print("Angle is: \(angle)")
                                self.drawPatty()
                                self.score += 1
                                self.scoreLabel.text = String(self.score)
                            }
                            else{
                                print("FAILURE--------", myData.rotationRate.x, "-----------")
                                print("Your angle is: \(angle), Patty angle is: \(self.pattyAngle)")
                            }
                        }
                    }
                }
            }
            
            // each time orientation changes, either return data or error in callback
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) {(data, error) in
                if let myData = data {
                  print(myData.attitude.yaw)
                    let angleInRadians: CGFloat = -2 * CGFloat(myData.attitude.yaw + Double.pi/4)
                    angle = -1 * angleInRadians
                    if (self.seconds > 0) {
                        self.drawCircle()
                        
                        if self.degrees(Double(angleInRadians)) > 0 {
                            self.drawLine(0)
                            angle = 0
                        }
                        else if self.degrees(Double(angleInRadians)) < -180 {
                            self.drawLine(Double.pi)
                            angle = CGFloat(Double.pi)
                        }
                        else {
                            self.drawLine(Double(angleInRadians))
                        }
                    }
                }
            }
        }
        else {
            drawCircle()
            drawLine(-1*Double.pi/2)
            playAgainButton.setTitle("Start game", for: .normal)
            playAgainButton.isHidden = false
        }
    }
    func drawCircle() {
        let center = CGPoint (x: self.circle.frame.size.width / 2, y: self.circle.frame.size.height / 2)
        let circleRadius = self.circle.frame.size.width / 2
        let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(Double.pi), endAngle: CGFloat(0), clockwise: true)
        self.semiCircleLayer.path = circlePath.cgPath
        self.semiCircleLayer.fillColor = UIColor(red: 0.9098, green: 0.8078, blue: 0.6078, alpha: 1.0).cgColor
        self.semiCircleLayer.lineWidth = 8
        self.circle.layer.addSublayer(self.semiCircleLayer)
        self.line.layer.sublayers = nil
    }
    
    func drawPatty() {
        let circleRadius = CGFloat(10)
        let random = arc4random_uniform(180)
        let randomRad = Double.pi*Double(random)/180
        self.pattyAngle = CGFloat(randomRad)
//        print("Random angle is \(randomRad) radians, which is \(random) degrees")
        let sine = CGFloat(sin(randomRad))
        let cosine = CGFloat(cos(randomRad))
        let xPos = (self.circle.frame.size.width / 2 + (cosine*self.circle.frame.size.width / 2) + (cosine*circleRadius))
        let yPos = (self.circle.frame.size.width / 2 + (sine*self.circle.frame.size.width / 2) + (sine*circleRadius))
//        print("/The patty is going to be printed on x: \(xPos) and y: \(yPos)")
        let center = CGPoint (x: xPos, y: 280-yPos)
        
        let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(-1*Double.pi), endAngle: CGFloat(Double.pi), clockwise: true)
        self.pattyLayer.path = circlePath.cgPath
        self.pattyLayer.fillColor = UIColor(red: 0.3765, green: 0.2627, blue: 0, alpha: 1.0).cgColor
        self.circleCopy.layer.addSublayer(self.pattyLayer)
        self.circleCopy.layer.zPosition = 3
    }
    
    func drawLine(_ angleInRadians: Double) {
        let length: CGFloat = 150
        let path = UIBezierPath()
        let layer = CAShapeLayer()
        
//        path.move(to: CGPoint(x: 0, y: 0))
//        path.addLine(to: CGPoint(x: 1, y: 0))
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0.9, y: 0))
        path.addLine(to: CGPoint(x: 0.9, y: 0.05))
        path.addLine(to: CGPoint(x: 1.1, y: 0.05))
        path.addLine(to: CGPoint(x: 1.1, y: -0.05))
        path.addLine(to: CGPoint(x: 0.9, y: -0.05))
        path.addLine(to: CGPoint(x: 0.9, y: 0))
        path.close()
        path.apply(.init(rotationAngle: CGFloat(angleInRadians)))
        path.apply(.init(scaleX: length, y: length))
        self.line.layer.addSublayer(layer)
        layer.path = path.cgPath
        layer.fillColor = UIColor.gray.cgColor
        layer.strokeColor = UIColor.gray.cgColor
        layer.lineWidth = 8
        
        self.line.layer.zPosition = 2
    }
    
    func degrees(_ radians: Double) -> Double {
        return 180/Double.pi * radians
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
