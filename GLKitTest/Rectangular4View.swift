//
//  Rectangular4View.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/21.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import GLKit

@available(*, deprecated)
class Rectangular4View: OGLESView {

    lazy var displyLink = CADisplayLink(target: self, selector: #selector(display1))
    let imageName = "timg-2.jpeg"
    var xDegree: Float = 0
    var yDegree: Float = 0
    var zDegree: Float = 0
    var bX:Bool = false
    var bY:Bool = false
    var bZ:Bool = false
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil{
            displyLink.invalidate()
        }
        
    }
    deinit {
        
        displyLink.invalidate()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        displyLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
           //6.开始绘制
           renderLayer()
    }
    //6.开始正式绘制
    func renderLayer() {
        //清除缓冲区
        glClear(GLbitfield(GL_DEPTH_BUFFER_BIT) | GLbitfield(GL_COLOR_BUFFER_BIT))
        //4.读取顶点着色程序、片元着色程序
        guard let program = DQShaderUtil.loadShader(vertexShaderName: "ver.vsh", fragmentShaderName: "frag.sh")else {
            return
        }
        //颜色和位置都是4维向量，虽然都是传了3个值，但是要用vec4
        //5.设置顶点、纹理坐标
        let vertexs:[GLfloat]  = [
            
            -0.5, 0.5, 0.0,      1.0, 0.0, 1.0, 0,1,//左上0
            0.5,  0.5, 0.0,      1.0, 0.0, 1.0, 1,1,//右上1
            -0.5, -0.5, 0.0,     1.0, 1.0, 1.0, 0,0,//左下2
            0.5, -0.5, 0.0,      1.0, 1.0, 1.0, 1,0,//右下3

            0.0, 0.0, 1.0,       0.0, 1.0, 0.0, 0.5,0.5//顶点4
        ]
        
        var index: [GLuint] = [
            0, 3, 2,
            0, 1, 3,
            0, 2, 4,
            0, 4, 1,
            2, 3, 4,
            1, 4, 3,
        ]
        //6.处理定点数据（copy到缓冲区）
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * 40, vertexs, GLenum(GL_DYNAMIC_DRAW))
        
        DQShaderUtil.setVertexAttribute(program: program, "position",3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), UnsafeRawPointer(bitPattern: 0))

        DQShaderUtil.setVertexAttribute(program: program, "verColor",3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3))

        DQShaderUtil.setVertexAttribute(program: program,"textCoordinate", 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), UnsafeRawPointer(bitPattern:MemoryLayout<GLfloat>.size * 6))
        
        
        
        var modelViewM = GLKMatrix4MakeTranslation(0, 0, -10)
        modelViewM = GLKMatrix4RotateX(modelViewM, xDegree/180 * Float.pi)
        modelViewM = GLKMatrix4RotateY(modelViewM, yDegree/180 * Float.pi)
        modelViewM = GLKMatrix4RotateZ(modelViewM, zDegree/180 * Float.pi)


        let projectM = GLKMatrix4MakePerspective(Float.pi/6, Float(self.frame.size.width/self.frame.size.height), 5, 20)
        var modelViewProjectM = GLKMatrix4Multiply(projectM, modelViewM).getArray()

        glUniformMatrix4fv(glGetUniformLocation(program, "matrix"), 1, GLboolean(GL_FALSE), &modelViewProjectM)
        
        //9.加载纹理图片
        DQShaderUtil.setUpTextureImage(imageName: imageName)
        //10.设置纹理采样器
        glEnable(GLenum(GL_CULL_FACE))
        glUniform1i(glGetUniformLocation(program, "colorMap"), 0)
        //11.绘制
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(index.count), GLenum(GL_UNSIGNED_INT), &index)
        
        //12.提交
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
        
        
    }
    
    @objc func display1(){
        xDegree += 0.5
        yDegree += 0.5
        zDegree += 0.5
        renderLayer()
    }
    
}
