//
//  CACubeViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/15.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

class CACubeViewController: UIViewController {

     var animateCube :UIView = UIView()
       var tansform = CATransform3DIdentity
       
       lazy var displyLink = CADisplayLink(target: self, selector: #selector(display))
       
       override func viewDidLoad() {
           super.viewDidLoad()

           initView()
           displyLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
       }
       @objc func display(){
           self.tansform = CATransform3DRotate(self.tansform, CGFloat.pi/360, -0.3, -1,0.7)
           self.animateCube.layer.sublayerTransform = self.tansform;//
       }
       
       func initView(){
           let frame  = CGRect(x: 0, y: 0, width: 200, height: 200)
           animateCube = UIView(frame: frame)
           animateCube.center = CGPoint(x: view.center.x, y: 400)
           view.addSubview(animateCube)
           
           let test = UIView(frame: frame)
           test.backgroundColor = UIColor.blue.withAlphaComponent(0.25)//最外边平面
           test.layer.transform = CATransform3DTranslate(test.layer.transform, 0, 0, 100)
           
           let test1 = UIView(frame: frame)
           test1.backgroundColor = UIColor.black.withAlphaComponent(0.5)
           test1.layer.transform = CATransform3DTranslate(test1.layer.transform, 0, 0, -100)//沿Z轴平移-100，最里边的平面
           
           let test2 = UIView(frame: frame)
           test2.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)//左边平面
           test2.layer.transform = CATransform3DTranslate(test2.layer.transform, -100, 0, 0)//3d平移（沿X轴平移-100）
           test2.layer.transform = CATransform3DRotate(test2.layer.transform, CGFloat.pi/2, 0, 1, 0)//3d旋转（沿Y轴旋转90度）
           
           let test3 = UIView(frame: frame)
           test3.backgroundColor = UIColor.purple.withAlphaComponent(0.5)//右边平面
           test3.layer.transform = CATransform3DTranslate(test3.layer.transform, 100, 0, 0)//沿X轴平移100
           test3.layer.transform = CATransform3DRotate(test3.layer.transform, CGFloat.pi/2, 0, 1, 0)//沿着Y轴旋转90度
           
           let test4 = UIView(frame: frame)
           test4.backgroundColor = UIColor.orange.withAlphaComponent(0.5)//上边平面
           test4.layer.transform = CATransform3DTranslate(test4.layer.transform, 0, 100, 0)//沿y轴平移100
           test4.layer.transform = CATransform3DRotate(test4.layer.transform, CGFloat.pi/2, 1, 0, 0)//沿着X轴旋转90度
           
           let test5 = UIView(frame: frame)
           test5.backgroundColor = UIColor.green.withAlphaComponent(0.5)//下边平面
           test5.layer.transform = CATransform3DTranslate(test5.layer.transform, 0, -100, 0)//沿y轴平移-100
           test5.layer.transform = CATransform3DRotate(test5.layer.transform, CGFloat.pi/2, -1, 0, 0)//沿着X轴旋转90度
           
           animateCube.addSubview(test)
           animateCube.addSubview(test1)
           animateCube.addSubview(test2)
           animateCube.addSubview(test3)
           animateCube.addSubview(test4)
           animateCube.addSubview(test5)
           
           self.animateCube.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)//2d变换, 缩小一些
           
           self.tansform.m34 = 1.0 / -500//透视效果，远小近大，深入屏幕里边小
           
           self.animateCube.layer.sublayerTransform = self.tansform;//
           
       }
       
       override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)
           displyLink.invalidate()
       }
       
       deinit {
         
       }

}
