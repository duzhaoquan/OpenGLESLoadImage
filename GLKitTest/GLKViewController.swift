//
//  GLKViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/14.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

 
import UIKit

/*
 CAEAGLLayer
 If you plan to use OpenGL for your rendering, use this class as the backing layer for your views by returning it from your view’s layerClass class method. The returned CAEAGLLayer object is a wrapper for a Core Animation surface that is fully compatible with OpenGL ES function calls.
 Prior to designating the layer’s associated view as the render target for a graphics context, you can change the rendering attributes you want using the drawableProperties property. This property lets you configure the color format for the rendering surface and whether the surface retains its contents.
 Because an OpenGL ES rendering surface is presented to the user using Core Animation, any effects and animations you apply to the layer affect the 3D content you render. However, for best performance, do the following:
 Set the layer’s opaque attribute to TRUE.
 Set the layer bounds to match the dimensions of the display.
 Make sure the layer is not transformed.
 Avoid drawing other layers on top of the CAEAGLLayer object. If you must draw other, non OpenGL content, you might find the performance cost acceptable if you place transparent 2D content on top of the GL content and also make sure that the OpenGL content is opaque and not transformed.
 When drawing landscape content on a portrait display, you should rotate the content yourself rather than using the CAEAGLLayer transform to rotate it.
 */

enum ESType:Int {
    case iamge = 1
    case rectangulr
    case light
    
}
@available(*, deprecated, message: "ios13")
class GLKViewController: UIViewController{
    
    var type:ESType = .iamge
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let tempView = UIView(frame: CGRect(x:10, y: 100, width: view.frame.width - 20, height: view.frame.height - 200))
        view.addSubview(tempView)
        
        switch type {
        case .iamge:
            //Set the layer bounds to match the dimensions of the display.
            //openGl ES layer所在的view.frame要等于父视图的bounds，否则图片位置错乱，所以添加一层layer
            let oesView = OESView(frame: tempView.bounds)
            oesView.backgroundColor = UIColor.purple
            tempView.addSubview(oesView)
        case .rectangulr:
            let oesView = Rectangular4View(frame: tempView.bounds)
            oesView.tag = 100
            oesView.backgroundColor = UIColor.purple
            tempView.addSubview(oesView)
            addbutton()
        case .light:
            let oesView = GLSLView(frame: tempView.bounds)
            oesView.backgroundColor = UIColor.purple
            tempView.addSubview(oesView)
        }
        
        
        
    }
 
    @objc func buttonClick(btn: UIButton){
        guard let recView = view.viewWithTag(100) as? Rectangular4View else{
            return
        }
        
        switch btn.tag {
        case 101:
            recView.bX = !recView.bX
        case 102:
            recView.bY = !recView.bY
        case 103:
            recView.bZ = !recView.bZ
        default:
            print("")
        }
        recView.xDegree *= recView.bX ? 1 : 0
        
        recView.yDegree *= recView.bY ? 1 : 0
        recView.zDegree *= recView.bZ ? 1 : 0
        
    }
    
    func addbutton() {
        let buttonX = UIButton(frame: CGRect.zero)
        buttonX.tag = 101
        buttonX.setTitle("rotateX", for: UIControl.State.normal)
        buttonX.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonX.backgroundColor = UIColor.gray
        let buttonY = UIButton(frame: CGRect.zero)
        buttonY.tag = 102
        buttonY.setTitle("rotateY", for: UIControl.State.normal)
        buttonY.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonY.backgroundColor = UIColor.gray
        
        let buttonZ = UIButton(frame: CGRect.zero)
        buttonZ.tag = 103
        buttonZ.setTitle("rotateZ", for: UIControl.State.normal)
        buttonZ.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonZ.backgroundColor = UIColor.gray
        
        view.addSubview(buttonX)
        view.addSubview(buttonY)
        view.addSubview(buttonZ)
        
        buttonX.translatesAutoresizingMaskIntoConstraints = false
        buttonY.translatesAutoresizingMaskIntoConstraints = false
        buttonZ.translatesAutoresizingMaskIntoConstraints = false

        buttonY.widthAnchor.constraint(equalTo: buttonX.widthAnchor).isActive = true
        buttonZ.widthAnchor.constraint(equalTo: buttonX.widthAnchor).isActive = true

        buttonX.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20).isActive = true
        buttonX.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        buttonX.heightAnchor.constraint(equalToConstant: 60).isActive = true

        buttonY.leftAnchor.constraint(equalTo: buttonX.rightAnchor,constant: 10).isActive = true
        buttonY.topAnchor.constraint(equalTo: buttonX.topAnchor).isActive = true
        buttonY.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor).isActive = true

        buttonZ.leftAnchor.constraint(equalTo: buttonY.rightAnchor,constant: 10).isActive = true
        buttonZ.topAnchor.constraint(equalTo: buttonX.topAnchor).isActive = true
        buttonZ.bottomAnchor.constraint(equalTo: buttonX.bottomAnchor).isActive = true
        buttonZ.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -20).isActive = true
    }
    
    func testImageDrow(){
        
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 300, width: 200, height: 300))
        imageView.backgroundColor = .red
        view.addSubview(imageView)
         
        guard let image = UIImage(named: "image.jpg")?.cgImage else {
           return
       }
       
       let width = image.width
       let height = image.height
       
       //开辟内存，绘制到这个内存上去
       let spriteData: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
       
       UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    
       //获取context
       let spriteContext = CGContext(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
       
       spriteContext?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
       
       imageView.image = UIImage(cgImage: (spriteContext?.makeImage()?.masking(imageRef(withPadding: 0, size: CGSize(width: width, height: height)))!)!)
       
       UIGraphicsEndImageContext()
    }
  fileprivate func imageRef(withPadding padding: CGFloat, size: CGSize) -> CGImage {
      // Build a context that's the same dimensions as the new size
      let colorSpace = CGColorSpaceCreateDeviceGray()
      let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo().rawValue | CGImageAlphaInfo.none.rawValue)
      let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
      
      // Start with a mask that's entirely transparent
      context?.setFillColor(UIColor.black.cgColor)
      context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
      
      // Make the inner part (within the border) opaque
      context?.setFillColor(UIColor.white.cgColor)
      context?.fill(CGRect(x: padding, y: padding, width: size.width - padding * 2, height: size.height - padding * 2))
      
      // Get an image of the context
      let maskImageRef = context?.makeImage()
      return maskImageRef!
  }

}


 


