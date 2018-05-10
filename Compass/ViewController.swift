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
//        CLManager.startUpdatingHeading()
        
        changeWorldBtn = UIButton(frame: CGRect(x: 10, y: 200, width: 40, height: 40))
        changeWorldBtn.setTitle("C", for: .normal)
        changeWorldBtn.setTitleColor(UIColor.blue, for: .normal)
        changeWorldBtn.addTarget(self, action: #selector(showWorldOrign), for: .touchUpInside)
        self.view.addSubview(changeWorldBtn)
        
        self.deviceMotionPush()
        
        
    }
    
    /// 改变世界坐标原点
    ///
    /// - Parameter angle: 磁极北方旋转的角度
    @objc func changeWorldOrigin() {
//        Y轴作为重力方向，只需绕着Y轴旋转世界原点坐标的方向，来匹配 东南西北。匹配后 Z轴正方向指向南方
        let matrix4_X = SCNMatrix4MakeRotation(0.0, 1.0, 0.0, 0.0)
        let matrix4_Y = SCNMatrix4MakeRotation(Float(angle), 0.0, 1.0, 0.0)
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
            print("heading = \(String(describing: motion?.heading))")
            print("gX = \(String(describing: motion?.gravity.x))")
            print("gY = \(String(describing: motion?.gravity.y))")
            print("gZ = \(String(describing: motion?.gravity.z))")
        }
    }
    
    private func gyroActive() {
        motionManager = CMMotionManager()
        let queue = OperationQueue()
        if motionManager.isGyroAvailable && motionManager.isGyroActive == false {
            motionManager.gyroUpdateInterval = 0.01
            motionManager.startGyroUpdates(to: queue) { (gyroData, error) in
                print("Rotation x = \(String(describing: gyroData?.rotationRate.x))")
                print("Rotation y = \(String(describing: gyroData?.rotationRate.y))")
                print("Rotation z = \(String(describing: gyroData?.rotationRate.z))")
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
        let direction = newHeading.trueHeading
        angle = direction/180 * .pi
        
        
        
//        print("magneticHeading = \(newHeading.magneticHeading) ,  trueHeading = \(newHeading.trueHeading)  , headingAccuracy = \(newHeading.headingAccuracy)")
        
//        if !directionSuccess {
//            directionSuccess = true
//            changeWorldOrigin()
//        }
        
        //设置动画
        UIView.animate(withDuration: 0.5) {
            self.compassImageView.transform = CGAffineTransform(rotationAngle: -CGFloat(self.angle))
            
        }
        
        
    }
}

