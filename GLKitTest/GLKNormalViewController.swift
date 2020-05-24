//
//  GLKNormalViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/22.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import GLKit

class DQvertexBuffer {
    var name = GLuint()
    var bufferSizeBytes = GLsizei()
    
    
    
}
struct DQNormalVertex {
    var vertexs:GLKVector3 //顶点坐标
    var normal:GLKVector3 //纹理坐标
}
struct SceneTriangle {
    var va:DQNormalVertex
    var vb:DQNormalVertex
    var vc:DQNormalVertex
    
    init(va:DQNormalVertex,vb:DQNormalVertex,vc:DQNormalVertex) {
        self.va = va
        self.vb = vb
        self.vc = vc
        
        updateNormal()
    }
    mutating func updateNormal() {
        let v1 = GLKVector3Subtract(self.va.vertexs, self.vb.vertexs)
        let v2 = GLKVector3Subtract(self.va.vertexs, self.vc.vertexs)
        //叉积求
        let nor = GLKVector3CrossProduct(v1, v2)
        let normal = GLKVector3Normalize(nor)
        
        va.normal = normal
        vb.normal = normal
        vc.normal = normal
        
    }
    
}
@available(*, deprecated, message: "")//消除警告
class GLKNormalViewController: UIViewController {

    let vertexCount = 12
    
    var xDegree: Float = 0
    var yDegree: Float = 0
    var zDegree: Float = 0
    
    var bufferID = GLuint()
    lazy var vertexs = UnsafeMutablePointer<DQNormalVertex>.allocate(capacity: MemoryLayout<DQNormalVertex>.size * vertexCount)
    lazy var sceneTriangles = [SceneTriangle]()
    var angle = 0
    var isPaused = false
   
    lazy var glkVIew:GLKView = {
       let glkView = GLKView(frame: CGRect(x: 50, y: 100, width: UIScreen.main.bounds.size.width - 100, height: UIScreen.main.bounds.size.width - 100))
       glkView.center = self.view.center
       glkView.delegate = self
       //设置深度缓冲区
       glkView.drawableDepthFormat = .format24
       glkView.backgroundColor = .purple
        
       view.addSubview(glkView)
       return glkView
   }()
   
   lazy var effect : GLKBaseEffect = {
       GLKBaseEffect()
   }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        //1.commit EAGLContext&GLKView
        if let context = EAGLContext(api: EAGLRenderingAPI.openGLES3){
            EAGLContext.setCurrent(context)
            glkVIew.context = context
        }
        
        setUpEffect()
        setUpVertexs()

        addbutton()
    }
    
    func addbutton() {
        let buttonX = UIButton(frame: CGRect(x: view.frame.width/2 - 160, y: view.frame.height - 200, width: 100, height: 50))
        buttonX.tag = 101
        buttonX.setTitle("rotateX", for: UIControl.State.normal)
        buttonX.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonX.backgroundColor = UIColor.purple
        let buttonY = UIButton(frame: CGRect(x: view.frame.width/2 - 50, y: view.frame.height - 200, width: 100, height: 50))
        buttonY.tag = 102
        buttonY.setTitle("rotateY", for: UIControl.State.normal)
        buttonY.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonY.backgroundColor = UIColor.purple
        
        let buttonZ = UIButton(frame: CGRect(x: view.frame.width/2 + 60, y: view.frame.height - 200, width: 100, height: 50))
        buttonZ.tag = 103
        buttonZ.setTitle("rotateZ", for: UIControl.State.normal)
        buttonZ.addTarget(self, action: #selector(buttonClick(btn:)), for: UIControl.Event.touchUpInside)
        buttonZ.backgroundColor = UIColor.purple
        
        view.addSubview(buttonX)
        view.addSubview(buttonY)
        view.addSubview(buttonZ)
        
    }
    @objc func buttonClick(btn: UIButton){
        switch btn.tag {
        case 101:
            xDegree += 15
        case 102:
            yDegree += 15
        case 103:
            zDegree += 15
        default:
            print("")
        }
        var modelviewM = GLKMatrix4MakeXRotation(xDegree/180 * Float.pi)
        modelviewM = GLKMatrix4RotateY(modelviewM, yDegree/180 * Float.pi)
        modelviewM = GLKMatrix4RotateZ(modelviewM, zDegree/180 * Float.pi)
        
        self.effect.transform.modelviewMatrix = modelviewM
        
        glkVIew.display()
        
    }
    func setUpVertexs(){
        /*
         b-----c
         ---e---
         a-----d
         */
        let va = DQNormalVertex(vertexs: GLKVector3(v: (-0.5,  -0.5, -0.5)), normal: GLKVector3(v: ( 0, 0, 1)))
        let vb = DQNormalVertex(vertexs: GLKVector3(v: (-0.5,  0.5, -0.5)), normal: GLKVector3(v: ( 0, 0, 1)))
        let vc = DQNormalVertex(vertexs: GLKVector3(v: (0.5, 0.5, -0.5)), normal: GLKVector3(v: ( 0, 0, 1)))
        let vd = DQNormalVertex(vertexs: GLKVector3(v: ( 0.5, -0.5, -0.5)), normal: GLKVector3(v: ( 0, 0, 1)))
        let ve = DQNormalVertex(vertexs: GLKVector3(v: ( 0.0,  0.0, 0.5)), normal: GLKVector3(v: ( 0, 0, 1)))
        
        sceneTriangles.append(SceneTriangle(va: va, vb: vd, vc: ve))
        sceneTriangles.append(SceneTriangle(va: va, vb: vb, vc: ve))
        sceneTriangles.append(SceneTriangle(va: vb, vb: vc, vc: ve))
        sceneTriangles.append(SceneTriangle(va: vc, vb: vd, vc: ve))
        
        
        vertexs[0] = sceneTriangles[0].va
        vertexs[1] = sceneTriangles[0].vb
        vertexs[2] = sceneTriangles[0].vc
        vertexs[3] = sceneTriangles[1].va
        vertexs[4] = sceneTriangles[1].vb
        vertexs[5] = sceneTriangles[1].vc
        vertexs[6] = sceneTriangles[2].va
        vertexs[7] = sceneTriangles[2].vb
        vertexs[8] = sceneTriangles[2].vc
        vertexs[9] = sceneTriangles[3].va
        vertexs[10] = sceneTriangles[3].vb
        vertexs[11] = sceneTriangles[3].vc
        
        var bufferID = GLuint()
        
        glGenBuffers(1, &bufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<DQNormalVertex>.size * 12, self.vertexs, GLenum(GL_STATIC_DRAW))
        
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint((GLKVertexAttrib.position.rawValue)), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<DQNormalVertex>.size), UnsafeRawPointer(bitPattern: 0))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint((GLKVertexAttrib.normal.rawValue)), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<DQNormalVertex>.size), UnsafeRawPointer(bitPattern: MemoryLayout<GLKVector3>.size + 4))
        
        
    }
    
    func setUpEffect(){
        self.effect.light0.enabled = GLboolean(GL_TRUE)
        self.effect.light0.diffuseColor = GLKVector4(v: (1,1, 0, 1))
        self.effect.light0.position = GLKVector4(v:  (0,1,1,1))
        
        var modelviewM = GLKMatrix4MakeXRotation(xDegree/180 * Float.pi)
        modelviewM = GLKMatrix4RotateY(modelviewM, yDegree/180 * Float.pi)
        modelviewM = GLKMatrix4RotateZ(modelviewM, zDegree/180 * Float.pi)
        modelviewM = GLKMatrix4Translate(modelviewM, 0, 0, -0)
        
        self.effect.transform.modelviewMatrix = modelviewM
        
    }

}

@available(*, deprecated, message: "")//消除警告
extension GLKNormalViewController : GLKViewDelegate{
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        glClearColor(0.3, 0.3, 0.3, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))
//        glEnable(GLenum(GL_CULL_FACE))
        effect.prepareToDraw()
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 12)
        
    }
    
    
}
