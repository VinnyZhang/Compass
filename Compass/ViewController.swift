//
//  ViewController.swift
//  Compass
//
//  Created by Zhang xiaosong on 2018/4/25.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import CoreLocation
import ARKit
import SceneKit
import CoreMotion

class ViewController: ARSCNBaseViewController {
    
    var compassImageView: UIImageView!
    var CLManager = CLLocationManager()
    var directionSuccess = false
    var changeWorldBtn: UIButton!
    var angle: Double!
    var motionManager: CMMotionManager!
    

    //    MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpMyViews()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    
    override func setupSession() {
        if ARWorldTrackingConfiguration.isSupported {//判断是否支持6个自由度
            let worldTracking = ARWorldTrackingConfiguration()
            //            worldTracking.planeDetection = .//平面检测
            worldTracking.isLightEstimationEnabled = true //光估计
            sessionConfiguration = worldTracking
        }
        else{
            let orientationTracking = AROrientationTrackingConfiguration()//3DOF
            sessionConfiguration = orientationTracking
        }
        CLManager.startUpdatingHeading()
        gameView.session.run(sessionConfiguration)
         
    }
    
    
    //    MARK: - internal methods
    
    

    
    /// 初始化
    func setUpMyViews() {
        compassImageView = UIImageView()
        self.view.addSubview(compassImageView)
        compassImageView.frame = CGRect(x: (self.view.frame.size.width - 150)/2.0, y: (self.view.frame.size.height - 180), width: 150, height: 150)
        compassImageView.image = UIImage(named: "compass")
        
        CLManager.delegate = self
        CLManager.startUpdatingHeading()
        
        changeWorldBtn = UIButton(frame: CGRect(x: 10, y: 200, width: 40, height: 40))
        changeWorldBtn.setTitle("C", for: .normal)
        changeWorldBtn.setTitleColor(UIColor.blue, for: .normal)
        changeWorldBtn.addTarget(self, action: #selector(showWorldOrign), for: .touchUpInside)
        self.view.addSubview(changeWorldBtn)
        
        
        
        
    }
    
    /// 改变世界坐标原点
    ///
    /// - Parameter angle: 磁极北方旋转的角度
    @objc func changeWorldOrigin() {
//        Y轴作为重力方向，只需绕着Y轴旋转世界原点坐标的方向，来匹配 东南西北。匹配后 Z轴正方向指向南方
        let matrix4_X = SCNMatrix4MakeRotation(0.0, 1.0, 0.0, 0.0)
        let matrix4_Y = SCNMatrix4MakeRotation(Float(self.angle), 0.0, 1.0, 0.0)
        let matrix4_Z = SCNMatrix4MakeRotation(0.0, 0.0, 0.0, 1.0)
        let matrix4_T = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
        
        let mXY =  SCNMatrix4Mult(matrix4_X, matrix4_Y)
        let mXYZ = SCNMatrix4Mult(mXY, matrix4_Z)
        let mT = SCNMatrix4Mult(mXYZ, matrix4_T)
        
        gameView.session.setWorldOrigin(relativeTransform: simd_float4x4(mT))
    }
    
    /// 展示世界坐标系原点
    @objc func showWorldOrign() {
        
        print("worldOrign = \(String(describing: gameView.session.currentFrame?.camera.eulerAngles))")
    }
    
    private func deviceMotionPush() {
        
        motionManager = CMMotionManager()
        let queue = OperationQueue()
        motionManager.deviceMotionUpdateInterval = 1.0
        motionManager.startDeviceMotionUpdates(to: queue) { (motion, error) in
            //手机位姿
            print("roll z = \(String(describing: motion?.attitude.roll))  pitch x = \(String(describing: motion?.attitude.pitch))  yaw y = \(String(describing: motion?.attitude.yaw))")
            
//            print("normal = \(String(describing: self.gameView.session.currentFrame?.camera.eulerAngles))")
            
            //取两位小数弧度
            var roll: Double = (motion?.attitude.roll)! * 100
            roll = roll.rounded()/100
            
            var pitch: Double = (motion?.attitude.pitch)! * 100
            pitch = pitch.rounded()/100
            
            var yaw: Double = (motion?.attitude.yaw)! * 100
            yaw = yaw.rounded()/100
            
//            print("roll = \(roll)")// 绕Z轴
//            print("pitch = \(pitch)")//绕X轴
//            print("yaw = \(yaw)")//绕Y轴
            
            if !self.directionSuccess {
                self.directionSuccess = true
                self.angle = self.angle - roll
//                self.angle = -roll
                self.changeWorldOrigin()
            }
            
            
            
            //z轴 = 0 x轴 > 0    = 0
            //z轴 < 0  X轴 =0    = .pi/2
            // z轴 < 0  x轴 > 0  =
            
            if roll == 0.00 && pitch == 0.00 {//没有在x轴 z轴上发生旋转
                if !self.directionSuccess {
                    print("change1")
                    self.motionManager.stopDeviceMotionUpdates()
                    self.directionSuccess = true
//                    self.angle = 0
//                    self.angle = .pi/2
//                    self.changeWorldOrigin()
                }
            }
            else if pitch == 0.00 && roll < 0.00{//没有在x轴发生旋转 z轴发生旋转
                if !self.directionSuccess {
                    print("change2")
                    self.motionManager.stopDeviceMotionUpdates()
                    self.directionSuccess = true
//                    self.angle = -.pi/2 + self.angle
//                    self.angle = .pi/2
//                    self.changeWorldOrigin()
                }
            }
            else if roll == 0.00 && pitch > 0.00 {//z轴未发生旋转 x轴向上发生旋转
                if !self.directionSuccess {
                    print("change3")
                    self.motionManager.stopDeviceMotionUpdates()
                    self.directionSuccess = true
//                    self.angle = .pi/2 + self.angle
//                    self.angle = .pi/2
//                    self.changeWorldOrigin()
                }
            }
            
            
            //计算Z轴的偏转
            if ((motion?.attitude.roll) != nil) && ((motion?.attitude.pitch) != nil) {
                
                //            self.angle = (motion?.attitude.yaw)! + (motion?.attitude.roll)!
//                self.angle = sqrt((motion?.attitude.roll)! * (motion?.attitude.roll)! + (motion?.attitude.pitch)! * (motion?.attitude.pitch)!)
//                self.angle = motion?.attitude.roll
//                self.angle = .pi/2
//
//                if !self.directionSuccess {
//                    self.directionSuccess = true
//                    self.changeWorldOrigin()
//                }
                
                
            }
            
            
        }
    }


}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //判断当前设备的朝向是否可用
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        
        //获取设备的朝向
//        let direction = newHeading.magneticHeading
        CLManager.stopUpdatingHeading()
        let direction = newHeading.trueHeading
        
        //如果世界坐标系中z轴的方向与手机垂直时z轴的方向一致
        angle = -((180 - direction)/180 * .pi)//旋转角度 ，z轴负方向指向南方
        
        //如果世界坐标系中z轴的方向与手机垂直时z轴的方向垂直
//        angle = (((180 - direction))/180 * .pi)
        
       
//        print("eulerAngles = \(String(describing: gameView.session.currentFrame?.camera.eulerAngles))")
        
        print("angle = \(angle)   direction = \(direction)")
        
        self.deviceMotionPush()
        
        
//        if !self.directionSuccess {
//            print("change3")
////            self.motionManager.stopDeviceMotionUpdates()
//            self.directionSuccess = true
//            //                    self.angle = .pi/2 + self.angle
//            //                    self.angle = .pi/2
////            self.changeWorldOrigin()
//        }
        
        
        //设置动画
        UIView.animate(withDuration: 0.3) {
            self.compassImageView.transform = CGAffineTransform(rotationAngle: -CGFloat(self.angle))
        }
        
        
    }
}

