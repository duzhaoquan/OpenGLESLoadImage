//
//  ViewController.swift
//  GLKitTest
//
//  Created by dzq_mac on 2020/5/14.
//  Copyright © 2020 dzq_mac. All rights reserved.
//

import UIKit
import GLKit

@available(*, deprecated, message: "ios13")//消除警告
class GLKImgeViewController: UIViewController {

    var glView:GLKView!
    var context:EAGLContext?
    var effect:GLKBaseEffect!
    var bufferID : GLuint = GLuint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1.初始化
        config()
        
        //2.顶点/纹理 坐标
        setUpVertexData()
        
        //设置纹理数据
        setImage()
        
    }

    func config(){
        //1创建GKLKView
        glView = GLKView(frame: CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: self.view.bounds.size.height - 200))
        
        self.view.addSubview(glView)
        //2.设置Context
        context = EAGLContext(api: EAGLRenderingAPI.openGLES3)
        if let con = context {
            EAGLContext.setCurrent(con)
            
            glView.context = con
        }
        /*3.配置视图创建的渲染缓存区.
        
        (1). drawableColorFormat: 颜色缓存区格式.
        简介:  OpenGL ES 有一个缓存区，它用以存储将在屏幕中显示的颜色。你可以使用其属性来设置缓冲区中的每个像素的颜色格式。
        
        GLKViewDrawableColorFormatRGBA8888 = 0,
        默认.缓存区的每个像素的最小组成部分（RGBA）使用8个bit，（所以每个像素4个字节，4*8个bit）。
        
        GLKViewDrawableColorFormatRGB565,
        如果你的APP允许更小范围的颜色，即可设置这个。会让你的APP消耗更小的资源（内存和处理时间）
        
        (2). drawableDepthFormat: 深度缓存区格式
        GLKViewDrawableDepthFormatNone = 0,意味着完全没有深度缓冲区
        GLKViewDrawableDepthFormat16,
        GLKViewDrawableDepthFormat24,
        如果你要使用这个属性（一般用于3D游戏），你应该选择GLKViewDrawableDepthFormat16
        或GLKViewDrawableDepthFormat24。这里的差别是使用GLKViewDrawableDepthFormat16
        将消耗更少的资源
        
        */
        glView.drawableColorFormat = .RGBA8888
        glView.drawableDepthFormat = .format16
        glView.delegate = self
        //4.设置背景颜色
        glClearColor(1, 1, 0, 1)
    }
    
    func setUpVertexData(){
        //1.设置顶点数组(顶点坐标,纹理坐标)
        /*
         纹理坐标系取值范围[0,1];原点是左下角(0,0);
         故而(0,0)是纹理图像的左下角, 点(1,1)是右上角.
         */
        let vertexs:[GLfloat]  = [
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            0.5, 0.5, 0.0,    1.0, 1.0, //右上
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            
            0.5, -0.5, 0.0,    1.0, 0.0, //右下
            -0.5, 0.5, 0.0,    0.0, 1.0, //左上
            -0.5, -0.5, 0.0,   0.0, 0.0, //左下
        ]

        
           /*
            顶点数组: 开发者可以选择设定函数指针，在调用绘制方法的时候，直接由内存传入顶点数据，也就是说这部分数据之前是存储在内存当中的，被称为顶点数组
            
            顶点缓存区: 性能更高的做法是，提前分配一块显存，将顶点数据预先传入到显存当中。这部分的显存，就被称为顶点缓冲区
            */
        ////2.开辟顶点缓存区
        //(1).创建顶点缓存区标识符ID
        glGenBuffers(1, &bufferID)
        //(2).绑定顶点缓存区.(明确作用)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferID)
        let size = MemoryLayout<[GLfloat]>.size * 30
        glBufferData(GLenum(GL_ARRAY_BUFFER), size, vertexs, GLenum(GL_STATIC_DRAW))
        
       //3.打开读取通道.
        /*
         (1)在iOS中, 默认情况下，出于性能考虑，所有顶点着色器的属性（Attribute）变量都是关闭的.
         意味着,顶点数据在着色器端(服务端)是不可用的. 即使你已经使用glBufferData方法,将顶点数据从内存拷贝到顶点缓存区中(GPU显存中).
         所以, 必须由glEnableVertexAttribArray 方法打开通道.指定访问属性.才能让顶点着色器能够访问到从CPU复制到GPU的数据.
         注意: 数据在GPU端是否可见，即，着色器能否读取到数据，由是否启用了对应的属性决定，这就是glEnableVertexAttribArray的功能，允许顶点着色器读取GPU（服务器端）数据。
       
        (2)方法简介
        glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
       
        功能: 上传顶点数据到显存的方法（设置合适的方式从buffer里面读取数据）
        参数列表:
            index,指定要修改的顶点属性的索引值,例如
            size, 每次读取数量。（如position是由3个（x,y,z）组成，而颜色是4个（r,g,b,a）,纹理则是2个.）
            type,指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT。
            normalized,指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）
            stride,指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0
            ptr指定一个指针，指向数组中第一个顶点属性的第一个组件。初始值为0
         */
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern: 0))
        //
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3))
        
    }

    func setImage() {
        
        guard  let imagePath = Bundle.main.path(forResource: "timg", ofType: "jpeg", inDirectory: nil),
               let image = UIImage(contentsOfFile: imagePath)?.cgImage
        else {
            return
            
        }
        let texture = try? GLKTextureLoader.texture(with: image, options: [GLKTextureLoaderOriginBottomLeft:true,GLKTextureLoaderGrayscaleAsAlpha:true,GLKTextureLoaderApplyPremultiplication:true])
        effect = GLKBaseEffect()
        if let textureInfo = texture{
            effect.texture2d0.enabled = GLboolean(GL_TRUE)
            effect.texture2d0.name = textureInfo.name
        }
        
        
        
    }
    
    deinit {
        glDeleteBuffers(1, &bufferID)
    }
}
//绘制视图的内容
/*
 GLKView对象使其OpenGL ES上下文成为当前上下文，并将其framebuffer绑定为OpenGL ES呈现命令的目标。然后，委托方法应该绘制视图的内容。
*/
@available(*, deprecated, message: "ios13")
extension GLKImgeViewController :GLKViewDelegate{
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        effect.prepareToDraw()
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        
        
    }
    
    
}

