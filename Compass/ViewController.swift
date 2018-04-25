//
//  ViewController.swift
//  Compass
//
//  Created by Zhang xiaosong on 2018/4/25.
//  Copyright © 2018年 Zhang xiaosong. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var compassImageView: UIImageView!
    var CLManager = CLLocationManager()

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
        compassImageView.frame = CGRect(x: (self.view.frame.size.width - 100)/2.0, y: (self.view.frame.size.height - 100)/2.0, width: 100, height: 100)
        compassImageView.image = UIImage(named: "compass")
        
        CLManager.delegate = self
        CLManager.startUpdatingHeading()
        
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
        
    }
}

