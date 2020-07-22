//
//  OESView.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/15.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit
/*
 swift 使用OpenGL ES 渲染一张图片
 关于CAEAGLLayer
 在制定该图层关联的视图作为渲染器的目标图形上下文之前,可以使用drawableProperties属性更改呈现属性。此属性允许您配置呈现表面的颜色格式以及表面是否保留其内容。
 因为OpenGL ES渲染的效果是要提交到用户使用的核心动画上，所以你使用在该layer上的任何效果和动画都会影响你渲染的3D效果，为了时性能最佳你应该做一下操作：
 设置图层为不透明，设置图层边界以匹配显示的尺寸，确保图层没有做变换。
 尽量避免在CAEAGLLayer添加其layer。如果必须要添加其他非OpenGL内容，那么如果你将透明的2D内容置于GL内容之上，并确保OpenGL内容是不透明的且没有转换过，那么性能还是可以接受的。
 当在竖屏上绘制横向内容时，你应该自己旋转内容，而不是使用CAEAGLLayer转换来旋转它。
*/

@available(*, deprecated)
class OESView: OGLESView {
    let imageName = "timg.jpeg"
    override func layoutSubviews() {
        super.layoutSubviews()
           //6.开始绘制
           renderLayer()
    }
    //6.开始正式绘制
    func renderLayer() {
        
        //4.读取顶点着色程序、片元着色程序
        guard let program = DQShaderUtil.loadShader(vertexShaderName: "shaderv.vsh", fragmentShaderName: "shaderf.fsh")else {
            return
        }
        //5.设置顶点、纹理坐标
        var vertexs:[GLfloat]  = [
             0.5, -0.5,0,     1.0, 0.0,
            -0.5, 0.5, 0,     0.0, 1.0,
            -0.5, -0.5,0,    0.0, 0.0,
                   
            0.5, 0.5, 0,      1.0, 1.0,
            -0.5, 0.5,0,     0.0, 1.0,
            0.5, -0.5,0,     1.0, 0.0,
        ]
        
        //图片缩放
        var imageScale:(CGFloat,CGFloat) = (1,1)
        if let image = UIImage(named: imageName)?.cgImage {
            let width = image.width
            let height = image.height
                   
            let scaleF = CGFloat(frame.height)/CGFloat(frame.width)
            let scaleI = CGFloat(height)/CGFloat(width)
                   
            imageScale = scaleF>scaleI ? (1,scaleI/scaleF) : (scaleF/scaleI,1)
        }
        for (i,v) in vertexs.enumerated(){
            if i % 5 == 0 {
                vertexs[i] = v * 2 * Float(imageScale.0)
            }
            if i % 5 == 1{
                vertexs[i] = v * 2 * Float(imageScale.1)
            }

        }
        
        
        //反转3.修改顶点纹理坐标
//        let vertexs:[GLfloat]  = [
//            0.5, -0.5, -1.0,     1.0f, 1.0f,
//           -0.5, 0.5, -1.0,     0.0f, 0.0f,
//           -0.5, -0.5, -1.0,    0.0f, 1.0f,
//
//           0.5,  0.5, -1.0,      1.0f, 0.0f,
//           -0.5, 0.5, -1.0,     0.0f, 0.0f,
//           0.5, -0.5, -1.0,     1.0f, 1.0f,
//        ]
        //6.处理定点数据（copy到缓冲区）
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * 30, vertexs, GLenum(GL_DYNAMIC_DRAW))
        
        //7.将顶点数据通过Programe传递到顶点着色程序的position属性上
        DQShaderUtil.setVertexAttribute(program: program, "position", 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern: 0))
        
        //8.纹理坐标数据通过Programe传递到顶点着色程序的textCoordinate属性上
        DQShaderUtil.setVertexAttribute(program: program,"textCoordinate", 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern:MemoryLayout<GLfloat>.size * 3))
        
        //9.加载纹理图片
        DQShaderUtil.setUpTextureImage(imageName: imageName)
        //10.设置纹理采样器
        glUniform1i(glGetUniformLocation(program, "colorMap"), 0)
        //附加反转
//        rotateTextureImage(program: program)
        //11.绘制
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        //12.提交
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
    
    //---------纹理反转----------
    /*
     由于iOSlayer中坐标系OpneGL坐标系不一致（顶点在左上角）所以加载出来的图片会到置，需要做一下处理使图片正，主要纹理反转的方法有如下：
    //1.矩阵反转
    //2.加载图片反转
     spriteContext?.translateBy(x: 0, y: CGFloat(height))//向下平移图片的高度
     spriteContext?.scaleBy(x: 1, y: -1)//反转图片
    //3.坐标反转
     改变纹理坐标
    //4.顶点着色器中反转
     varyTextCoord = vec2(textCoordinate.x,1.0-textCoordinate.y);
    //5.片元着色器中反转
     gl_FragColor = texture2D(colorMap, vec2(varyTextCoord.x,1.0 - varyTextCoord.y));
     
     因为想着在着色器程序中使用较少的代码原则，是倾向于使用第2种方法
    */
    func rotateTextureImage(program:GLuint)  {
    
        //获取旋转180度的矩阵
        var rotateM = GLKMatrix4MakeZRotation(Float.pi).getArray()

        rotateM = GLKMatrix4Identity.getArray()
        glUniformMatrix4fv(glGetUniformLocation(program, "rotateMatrix"), 1, 0, rotateM)
    }
    
    
}

