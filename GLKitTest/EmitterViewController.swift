//
//  EmitterViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/24.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit

class EmitterViewController: UIViewController {

    var emitterLayer = CAEmitterLayer()
    let cell = CAEmitterCell()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        emitter1()

        
        
    }
    
    func emitter1() {
        
        let emitterLayer = CAEmitterLayer()
        self.view.layer.addSublayer(emitterLayer)
        self.emitterLayer = emitterLayer
        emitterLayer.emitterMode = .outline
        emitterLayer.renderMode = .oldestLast
        emitterLayer.emitterShape = .circle
        emitterLayer.emitterPosition = CGPoint(x: view.center.x, y: view.center.y)
        emitterLayer.emitterSize = CGSize(width: 100, height: 100)
        
        
        
        cell.contents = UIImage(named: "jinbi.png")?.cgImage
        cell.alphaSpeed = -1
        cell.alphaRange = 0.10
        cell.lifetime = 300
        cell.lifetimeRange = 100
        cell.velocity = 1
        cell.velocityRange = 1
        cell.scale = 0.01
        cell.scaleRange = 0.02
        emitterLayer.emitterCells = [cell]
        
        
        let fireworksEmitter = CAEmitterLayer()
        let  viewBounds = self.view.layer.bounds;
        fireworksEmitter.emitterPosition = CGPoint(x: viewBounds.size.width/2.0, y: viewBounds.size.height);
        fireworksEmitter.emitterSize    = CGSize(width: 1, height: 0)
        fireworksEmitter.emitterMode    = .outline
        fireworksEmitter.emitterShape    = .line
        fireworksEmitter.renderMode        = .additive
        //fireworksEmitter.seed = 500;//(arc4random()%100)+300;
        
        // Create the rocket
        let  rocket = CAEmitterCell()
        
        rocket.birthRate        = 6.0;
        rocket.emissionRange    = 0.12 * CGFloat.pi;  // some variation in angle
        rocket.velocity            = 500;
        rocket.velocityRange    = 150;
        rocket.yAcceleration    = 0;
        rocket.lifetime            = 2.02;    // we cannot set the birthrate < 1.0 for the burst
        
        rocket.contents            = UIImage(named: "hongbao")?.cgImage
        rocket.scale            = 0.03;
        //    rocket.color            = [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor];
        rocket.greenRange        = 1.0;        // different colors
        rocket.redRange            = 1.0;
        rocket.blueRange        = 1.0;
        
        rocket.spinRange        = CGFloat.pi;        // slow spin
        
        
        
        // the burst object cannot be seen, but will spawn the sparks
        // we change the color here, since the sparks inherit its value
        let burst = CAEmitterCell()
        
        burst.birthRate            = 1.0;        // at the end of travel
        burst.velocity            = 0;
        burst.scale                = 2.5;
        burst.redSpeed            = -1.5;        // shifting
        burst.blueSpeed            = +1.5;        // shifting
        burst.greenSpeed        = +1.0;        // shifting
        burst.lifetime            = 0.35;
        
        // and finally, the sparks
        let spark = CAEmitterCell()
        
        spark.birthRate            = 666;
        spark.velocity            = 125;
        spark.emissionRange        = 2 * CGFloat.pi;    // 360 deg
        spark.yAcceleration        = 75;        // gravity
        spark.lifetime            = 3;
        
        spark.contents            = UIImage(named: "fire")?.cgImage
        spark.scale               = 0.5;
        spark.scaleSpeed          = -0.2;
        spark.greenSpeed          = -0.1;
        spark.redSpeed            = 0.4;
        spark.blueSpeed            = -0.1;
        spark.alphaSpeed        = -0.5;
        spark.spin                = 2 * CGFloat.pi;
        spark.spinRange            = 2 * CGFloat.pi;
        
        // putting it together
        fireworksEmitter.emitterCells    = [rocket];
        rocket.emitterCells                = [burst];
        burst.emitterCells                = [spark];
        
        self.view.layer.addSublayer(fireworksEmitter)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cell.birthRate = 10
        emitterLayer.emitterCells?.append(cell)
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: {
            self.emitterLayer.emitterCells?.removeAll()
        })
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }

}
