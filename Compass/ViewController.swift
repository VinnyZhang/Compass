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

class ViewController: ARSCNBaseViewController {
    
    var compassImageView: UIImageView!
    var CLManager = CLLocationManager()
    var directionSuccess = false
    

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
    
    
    //    MARK: - internal methods

    
    /// 初始化
    func setUpMyViews() {
        compassImageView = UIImageView()
        self.view.addSubview(compassImageView)
        compassImageView.frame = CGRect(x: (self.view.frame.size.width - 150)/2.0, y: (self.view.frame.size.height - 180), width: 150, height: 150)
        compassImageView.image = UIImage(named: "compass")
        
        CLManager.delegate = self
        CLManager.startUpdatingHeading()
        
    }
    
    /// 改变世界坐标原点
    ///
    /// - Parameter angle: 磁极北方旋转的角度
    func changeWorldOrigin(angle: Float) {
//        Y轴作为重力方向，只需绕着Y轴旋转世界原点坐标的方向，来匹配 东南西北。匹配后 Z轴正方向指向南方
        let matrix4_X = SCNMatrix4MakeRotation(0.0, 1.0, 0.0, 0.0)
        let matrix4_Y = SCNMatrix4MakeRotation(angle, 0.0, 1.0, 0.0)
        let matrix4_Z = SCNMatrix4MakeRotation(0.0, 0.0, 0.0, 1.0)
        let matrix4_T = SCNMatrix4MakeTranslation(0.0, 0.0, 0.0)
        
        let mXY =  SCNMatrix4Mult(matrix4_X, matrix4_Y)
        let mXYZ = SCNMatrix4Mult(mXY, matrix4_Z)
        let mT = SCNMatrix4Mult(mXYZ, matrix4_T)
        
        gameView.session.setWorldOrigin(relativeTransform: simd_float4x4(mT))
    }


}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //判断当前设备的朝向是否可用
        guard newHeading.headingAccuracy > 0 else {
            return
        }
        
        //获取设备的朝向
        let direction = newHeading.magneticHeading
        let angle = direction/180 * .pi
        
        //设置动画
        UIView.animate(withDuration: 0.5) {
            self.compassImageView.transform = CGAffineTransform(rotationAngle: -CGFloat(angle))
            
        }
        
        if !directionSuccess {
            directionSuccess = true
            changeWorldOrigin(angle: Float(angle))
        }
        
        
        
    }
}

