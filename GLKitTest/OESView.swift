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

let imageName = "timg.jpeg"
@available(*, deprecated)
class OESView: UIView {
    
    var glLayer:CAEAGLLayer!
    var context :EAGLContext!
    var colorRederBuffer = GLuint()
    var colorFrameBuffer = GLuint()
    
    var imageScale:(CGFloat,CGFloat) = (1,1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let image = UIImage(named: imageName)?.cgImage {
           let width = image.width
           let height = image.height
                  
           let scaleF = CGFloat(frame.height)/CGFloat(frame.width)
           let scaleI = CGFloat(height)/CGFloat(width)
                  
           imageScale = scaleF>scaleI ? (1,scaleI/scaleF) : (scaleI/scaleF,1)
       }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
       
        
       
        //1设置图层
        createGLLayer()
        
        //2.设置图形上下文
        setUpContext()
        
        //3.清除缓冲区
        clearRenderBufferAndFrameBuffer()
        
        //4.设置着色器缓冲器
        setUpRenderBuffer()
        
        //5.设置框架缓冲器（管理RenderBuffer）
        setUpFrameBuffer()
        
        //6.开始绘制
        renderLayer()
    }


    //1.设置图层
    /*
    kEAGLDrawablePropertyRetainedBacking  表示绘图表面显示后，是否保留其内容。
    kEAGLDrawablePropertyColorFormat
        可绘制表面的内部颜色缓存区格式，这个key对应的值是一个NSString指定特定颜色缓存区对象。默认是kEAGLColorFormatRGBA8；
    
        kEAGLColorFormatRGBA8：32位RGBA的颜色，4*8=32位
        kEAGLColorFormatRGB565：16位RGB的颜色，
        kEAGLColorFormatSRGBA8：sRGB代表了标准的红、绿、蓝，即CRT显示器、LCD显示器、投影机、打印机以及其他设备中色彩再现所使用的三个基本色素。sRGB的色彩空间基于独立的色彩坐标，可以使色彩在不同的设备使用传输中对应于同一个色彩坐标体系，而不受这些设备各自具有的不同色彩坐标的影响。
    */
    func createGLLayer() {
        glLayer = (self.layer as! CAEAGLLayer)

        self.contentScaleFactor = UIScreen.main.scale
        
        glLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking : false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8]
        
    }
    //重写父类类属性layerClass，将View返回的图层从CALayer替换成CAEAGLLayer
    override class var layerClass: AnyClass{
        return CAEAGLLayer.self
    }
    //2.设置图形上下文
    /*
     1).指定OpenGL ES 渲染API版本，我们使用3.0，2.0和3.0差不多
     2).创建图形上下文
     3).判断是否创建成功
     4).设置图形上下文
     */
    func setUpContext(){
        if let con = EAGLContext(api: EAGLRenderingAPI.openGLES3){
            EAGLContext.setCurrent(con)
            self.context = con
        }else{
            print("创建context失败")
        }
    }
    /*
    3.清除缓冲区
    buffer分为frame buffer 和 render buffer2个大类。
    其中frame buffer 相当于render buffer的管理者。
    frame buffer object即称FBO。
    render buffer则又可分为3类。colorBuffer、depthBuffer、stencilBuffer。
    */
    func clearRenderBufferAndFrameBuffer() {
        glDeleteBuffers(1, &colorRederBuffer)
        colorRederBuffer = 0
        
        glDeleteBuffers(1, &colorFrameBuffer)
        colorFrameBuffer = 0
    }
    //4.设置渲染缓冲区
    func setUpRenderBuffer() {
        //申请一个缓冲区标志
        glGenRenderbuffers(1, &colorRederBuffer)
        //将标识符绑定到GL_RENDERBUFFER
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRederBuffer)
        //将可绘制对象drawable object's  CAEAGLLayer的存储绑定到OpenGL ES renderBuffer对象
        context.renderbufferStorage(Int(GLenum(GL_RENDERBUFFER)), from: glLayer)
        
    }
    /*
    5.设置帧缓冲区
    生成帧缓存区之后，则需要将renderbuffer跟framebuffer进行绑定，
    调用glFramebufferRenderbuffer函数进行绑定到对应的附着点上，后面的绘制才能起作用
    */
    func setUpFrameBuffer() {
        //申请一个缓冲区标志
        glGenRenderbuffers(1, &colorFrameBuffer)
        //将标识符绑定到GL_FRAMEBUFFER
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), colorFrameBuffer)
        //将渲染缓存区myColorRenderBuffer 通过glFramebufferRenderbuffer函数绑定到 GL_COLOR_ATTACHMENT0上。
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRederBuffer)
    }
    //6.开始正式绘制
    func renderLayer() {
        //1.设置背景颜色
        glClearColor(1, 0, 0, 1)
        //2.清楚深度缓冲区
        glClear(GLbitfield(GL_DEPTH_BUFFER_BIT))
        //3.设置视口
        let scale = UIScreen.main.scale
        glViewport(GLint(frame.origin.x * scale), GLint(frame.origin.y * scale), GLsizei(frame.size.width * scale), GLsizei(frame.size.height * scale))
        //4.读取顶点着色程序、片元着色程序
        let spath = Bundle.main.path(forResource: "shaderv", ofType: "vsh") ?? ""
        let fpath = Bundle.main.path(forResource: "shaderf", ofType: "fsh") ?? ""
        let (sucess,program) = loadShader(vertexPath: spath, fragmentPath: fpath)
        if !sucess {
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
        var verbuffer = GLuint()
        glGenBuffers(1, &verbuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), verbuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * 30, vertexs, GLenum(GL_DYNAMIC_DRAW))
        
        //7.将顶点数据通过Programe传递到顶点着色程序的position属性上
        //1.glGetAttribLocation,用来获取vertex attribute的入口的.
        //2.告诉OpenGL ES,通过glEnableVertexAttribArray，打开开关
        //3.最后数据是通过glVertexAttribPointer传递过去的。
        
        //顶点坐标
        //(1)注意：第二参数字符串必须和shaderv.vsh中的输入变量：position保持一致
        let positon = glGetAttribLocation(program, "position")
         //(2).设置合适的格式从buffer里面读取数据
        glEnableVertexAttribArray(GLuint(positon))
        //(3).设置读取方式
        //参数1：index,顶点数据的索引
        //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
        //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
        //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
        //参数5：stride,连续顶点属性之间的偏移量，默认为0；
        //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
        glVertexAttribPointer(GLuint(positon), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern: 0))
        
        //8.纹理坐标数据通过Programe传递到顶点着色程序的textCoordinate属性上
        let texture = glGetAttribLocation(program, "textCoordinate")
        glEnableVertexAttribArray(GLuint(texture))
        glVertexAttribPointer(GLuint(texture), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size * 5), UnsafeRawPointer(bitPattern:MemoryLayout<GLfloat>.size * 3))
        
        //9.加载纹理图片
        setUpTextureImage(imageName: imageName)
        //10.设置纹理采样器
        glUniform1i(glGetUniformLocation(program, "colorMap"), 0)
        //附加反转
//        rotateTextureImage(program: program)
        //11.绘制
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        //12.提交
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
   
    //加载一张纹理图片
    func setUpTextureImage(imageName:String) {
        guard let image = UIImage(named: imageName)?.cgImage else {
            return
        }
        
        let width = image.width
        let height = image.height
        
        //开辟内存，绘制到这个内存上去
        let spriteData: UnsafeMutablePointer = UnsafeMutablePointer<GLubyte>.allocate(capacity: MemoryLayout<GLubyte>.size * width * height * 4)
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        //获取context
        let spriteContext = CGContext(data: spriteData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)
        //2.图片反转2
        spriteContext?.translateBy(x: 0, y: CGFloat(height))//向下平移图片的高度
        spriteContext?.scaleBy(x: 1, y: -1)//反转图片
        
        spriteContext?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsEndImageContext()
        
        //绑定纹理
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        //设置纹理参数
        //缩小/放大过滤器
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        //环绕方式
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        //载入纹理
        /*
        参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
        参数2：加载的层次，一般设置为0
        参数3：纹理的颜色值GL_RGBA
        参数4：宽
        参数5：高
        参数6：border，边界宽度
        参数7：format
        参数8：type
        参数9：纹理数据
        */
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE),spriteData)
        //释放内存
        free(spriteData)
    }
    
    //封装加载着色器程序方法
    func loadShader(vertexPath:String,fragmentPath:String) -> (Bool,GLuint){
        let program:GLuint = glCreateProgram()
        
        //vertexShader
        guard let verShader:GLuint = compileShader(type: GLenum(GL_VERTEX_SHADER), filePath: vertexPath) else {
            return (false,program)
            
        }
        //把编译后的着色器代码附着到最终的程序上
        glAttachShader(program, verShader)
        //释放不需要的shader
        glDeleteShader(verShader)
        
        //fragmentShader
        guard let fragShader = compileShader(type: GLenum(GL_FRAGMENT_SHADER), filePath: fragmentPath)else{
            return (false,program)
            
        }
        glAttachShader(program, fragShader)
        glDeleteShader(fragShader)
        
        //链接着色器代程序
        glLinkProgram(program)
        //获取链接状态
        var status:GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        if status == GLenum(GL_FALSE){
            print("link Error")
            //打印错误信息
            let message = UnsafeMutablePointer<GLchar>.allocate(capacity: 512)
            glGetProgramInfoLog(program, GLsizei(MemoryLayout<GLchar>.size * 512), nil, message)
            let str = String.init(utf8String: message)
            print(str ?? "没有取到ProgramInfoLog")
            return (false,program)
        }else{
            print("link sucess!")
            //链接成功，使用着色器程序
            glUseProgram(program)
            return (true,program)
        }
        
    }
    //读取并编译着色器程序
    func compileShader(type:GLenum,filePath:String) -> GLuint? {
        //创建一个空着色器
        let verShader:GLuint = glCreateShader(type)
        //获取源文件中的代码字符串
        guard let shaderString = try? String.init(contentsOfFile: filePath, encoding: String.Encoding.utf8)else    {
            return nil
        }
        //转成C字符串赋值给已创建的shader
        shaderString.withCString { (pointer) in
            var pon:UnsafePointer<GLchar>? = pointer
            glShaderSource(verShader, 1, &pon, nil)
        }
        
        //编译
        glCompileShader(verShader)
       
        return verShader
    }
    
    //稀构方法中清空缓冲区
    deinit {
        glDeleteBuffers(1, &colorFrameBuffer)
        glDeleteBuffers(1, &colorRederBuffer)
        
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

extension GLKMatrix4 {
    
    /// 转成数组
    /// - Returns: 结果数组
    func getArray() ->[Float] {
         [
            m00,m01,m02,m03,
            m10,m11,m12,m13,
            m20,m21,m22,m23,
            m30,m31,m32,m33,
        ]
        
    }
    
}
