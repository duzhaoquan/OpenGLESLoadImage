//
//  GLSLView.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/23.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import GLKit

@available(*, deprecated)
class GLSLView: OGLESView {

    var index:Int = 0
    
    lazy var displyLink = CADisplayLink(target: self, selector: #selector(display2))
    var program:GLuint = 0
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
        displyLink.preferredFramesPerSecond = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //4.读取顶点着色程序、片元着色程序
        guard let pro = DQShaderUtil.loadShader(vertexShaderName: "lightVer.vsh", fragmentShaderName: "lightFrag.fsh")else {
            return
        }
        program = pro
        //5.设置顶点、纹理坐标
        let vertexs:[GLfloat]  = vertexsCube
    
        //6.处理定点数据（copy到缓冲区）
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * vertexs.count, vertexs, GLenum(GL_DYNAMIC_DRAW))
        
        //7.将顶点数据通过Programe传递到顶点着色程序的position属性上
        glEnableVertexAttribArray(0)
        glEnableVertexAttribArray(1)
        glEnableVertexAttribArray(2)
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), UnsafeRawPointer(bitPattern: 0))
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3))
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 8), UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 6))
        
        //9.加载纹理图片
        DQShaderUtil.setUpTextureImage(imageName: "image.jpg",texture: GLenum(GL_TEXTURE0))
        //10.设置纹理采样器
        glUniform1i(glGetUniformLocation(program, "Material.Texture"), 0)

        DQShaderUtil.setUpTextureImage(imageName: "hulu.jpg",map: true,texture: GLenum(GL_TEXTURE1))

        glUniform1i(glGetUniformLocation(program, "Material.specularTexture"), 0)
        
        //6.开始绘制
        renderLayer()
    }
    
    

    func renderLayer() {
        index += 1
        if index > 100 {
            index = 0
        }
        if index%4 == 0{
            return
        }
        glClearColor(0.5, 0.5, 0.5, 1)
        glEnable(GLenum(GL_DEPTH_TEST))
        
        glClear(GLbitfield(GL_DEPTH_BUFFER_BIT) | GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUniform3f(glGetUniformLocation(program, "lightColor"), 1, 1, 0)

        var persM = GLKMatrix4MakePerspective(45/180*Float.pi, Float(frame.width/frame.height), 1, 80).getArray()
        
        glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GLboolean(GL_FALSE), &persM)

        let camX:Float = Float(sin(CACurrentMediaTime()) * 10.0)
        let camZ:Float = Float(cos(CACurrentMediaTime()) * 10.0)
        let viewPo = GLKVector3(v: (camX,camX,camZ))

        var view = GLKMatrix4Scale(GLKMatrix4MakeLookAt(camX, camX, camZ, 0, 0, 0, 0, 1, 0), 2, 2, 2).getArray()
        
        glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GLboolean(GL_FALSE), &view)

        glUniform3f(glGetUniformLocation(program,"viewPo"), viewPo.x, viewPo.y, viewPo.z)

        
        glUniform3f(glGetUniformLocation(program, "lightPo"), 1.2, 1, 2)


        //11.绘制
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
        //12.提交
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
        
        
    }
    
    @objc func display2(){
        renderLayer()
    }

}
