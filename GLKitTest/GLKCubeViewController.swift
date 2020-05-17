//
//  GLKCubeViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/14.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import GLKit

struct DQVertex {
    var vertexs:GLKVector3 //顶点坐标
    var textures:GLKVector2//纹理坐标
}
@available(*, deprecated, message: "")//消除警告
class GLKCubeViewController: UIViewController {

    let vertexCount = 36
    var bufferID = GLuint()
    lazy var vertexs = UnsafeMutablePointer<DQVertex>.allocate(capacity: MemoryLayout<DQVertex>.size * vertexCount)
    
    var angle = 0
    var isPaused = false
    
    
    lazy var glkVIew:GLKView = {
        let glkView = GLKView(frame: CGRect(x: 50, y: 100, width: UIScreen.main.bounds.size.width - 100, height: UIScreen.main.bounds.size.width - 100))
        glkView.center = self.view.center
        glkView.delegate = self
        //设置深度缓冲区
        glkView.drawableDepthFormat = .format24
        glkView.backgroundColor = .purple
        glClearColor(1, 0.2, 0.8, 1)
        view.addSubview(glkView)
        return glkView
    }()
    
    lazy var effect : GLKBaseEffect = {
        GLKBaseEffect()
    }()
    
    lazy var displyLink = CADisplayLink(target: self, selector: #selector(display))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
       
        //1.commit EAGLContext&GLKView
        if let context = EAGLContext(api: EAGLRenderingAPI.openGLES3){
            EAGLContext.setCurrent(context)
            glkVIew.context = context
        }
        
        //2.顶点坐标
        setUpVertexs()
        
        //3.设置纹理
        setUpTexture()
        
        //4.循环
        displyLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    func setUpVertexs() {
        
        //前
        vertexs[0] = DQVertex(vertexs: GLKVector3(v: (-0.5,0.5,0.5)), textures: GLKVector2(v: (0,1)))
        vertexs[1] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[2] = DQVertex(vertexs: GLKVector3(v: (0.5, 0.5, 0.5)), textures: GLKVector2(v: (1,1)))

        vertexs[3] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[4] = DQVertex(vertexs: GLKVector3(v: (0.5, 0.5, 0.5)), textures: GLKVector2(v: (1,1)))
        vertexs[5] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,0.5)), textures: GLKVector2(v: (1,0)))

        //后
        vertexs[6] = DQVertex(vertexs: GLKVector3(v: (-0.5, 0.5, -0.5)), textures: GLKVector2(v: (0,1)))
        vertexs[7] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[8] = DQVertex(vertexs: GLKVector3(v: (0.5, 0.5, -0.5)), textures: GLKVector2(v: (1,1)))

        vertexs[9] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[10] = DQVertex(vertexs: GLKVector3(v: (0.5,0.5,-0.5)), textures: GLKVector2(v: (1,1)))
        vertexs[11] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,-0.5)), textures: GLKVector2(v: (1,0)))

        //上
        vertexs[12] = DQVertex(vertexs: GLKVector3(v: (-0.5, 0.5, 0.5)), textures: GLKVector2(v: (0,1)))
        vertexs[13] = DQVertex(vertexs: GLKVector3(v: (-0.5,0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[14] = DQVertex(vertexs: GLKVector3(v: (0.5, 0.5, 0.5)), textures: GLKVector2(v: (1,1)))

        vertexs[15] = DQVertex(vertexs: GLKVector3(v: (-0.5,0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[16] = DQVertex(vertexs: GLKVector3(v: (0.5,0.5,0.5)), textures: GLKVector2(v: (1,1)))
        vertexs[17] = DQVertex(vertexs: GLKVector3(v: (0.5,0.5,-0.5)), textures: GLKVector2(v: (1,0)))

        //下
        vertexs[18] = DQVertex(vertexs: GLKVector3(v: (-0.5, -0.5, 0.5)), textures: GLKVector2(v: (0,1)))
        vertexs[19] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[20] = DQVertex(vertexs: GLKVector3(v: (0.5, -0.5, 0.5)), textures: GLKVector2(v: (1,1)))

        vertexs[21] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[22] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,0.5)), textures: GLKVector2(v: (1,1)))
        vertexs[23] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,-0.5)), textures: GLKVector2(v: (1,0)))

        //左
        vertexs[24] = DQVertex(vertexs: GLKVector3(v: (-0.5,0.5, -0.5)), textures: GLKVector2(v: (0,1)))
        vertexs[25] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[26] = DQVertex(vertexs: GLKVector3(v: (-0.5, 0.5, 0.5)), textures: GLKVector2(v: (1,1)))

        vertexs[27] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[28] = DQVertex(vertexs: GLKVector3(v: (-0.5,0.5,0.5)), textures: GLKVector2(v: (1,1)))
        vertexs[29] = DQVertex(vertexs: GLKVector3(v: (-0.5,-0.5,0.5)), textures: GLKVector2(v: (1,0)))

        //右
        vertexs[30] = DQVertex(vertexs: GLKVector3(v: (0.5, 0.5,-0.5)), textures: GLKVector2(v: (0,1)))
        vertexs[31] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[32] = DQVertex(vertexs: GLKVector3(v: (0.5, 0.5, 0.5)), textures: GLKVector2(v: (1,1)))

        vertexs[33] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,-0.5)), textures: GLKVector2(v: (0,0)))
        vertexs[34] = DQVertex(vertexs: GLKVector3(v: (0.5,0.5,0.5)), textures: GLKVector2(v: (1,1)))
        vertexs[35] = DQVertex(vertexs: GLKVector3(v: (0.5,-0.5,0.5)), textures: GLKVector2(v: (1,0)))
        

        let size = MemoryLayout<DQVertex>.size * vertexCount
        
        glGenBuffers(1, &bufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), size, self.vertexs, GLenum(GL_STATIC_DRAW))
        
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint((GLKVertexAttrib.position.rawValue)), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<DQVertex>.size), UnsafeRawPointer(bitPattern: 0))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<DQVertex>.size), UnsafeRawPointer(bitPattern: MemoryLayout<GLKVector3>.size + 4))
        
    }
    func setUpTexture(){
        guard let image = UIImage(named: "timg-2.jpeg")?.cgImage else {
            return
        }
        
        guard let textureInfo :GLKTextureInfo = try? GLKTextureLoader.texture(with: image, options: [GLKTextureLoaderOriginBottomLeft : true]) else{
            return
        }
        
        effect.texture2d0.enabled = GLboolean(true)
        effect.texture2d0.name = textureInfo.name
        effect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
        
    }
    
    @objc func display(){
        if isPaused{
            return
        }
        angle = (angle + 1) % 720
        
        effect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(Float(angle/2)), 0.3, 1, 0.7)
        
        glkVIew.display()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displyLink.invalidate()
        
    }
    
    deinit {
        //析构函数中释放内存
        if (EAGLContext.current() != nil){
            EAGLContext.setCurrent(nil)
        }
        //自己开辟的的需要自己释放
        vertexs.deallocate()
        glDeleteBuffers(1, &bufferID)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPaused = !isPaused
    }

}
@available(*, deprecated, message: "")
extension GLKCubeViewController : GLKViewDelegate{
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        
        glEnable(GLenum(GL_DEPTH_TEST))
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT))
        effect.prepareToDraw()
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertexCount))
        
        
    }
    
    
}
