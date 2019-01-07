# OpenGL_NK
1、OpenGL 是在三维坐标系上绘制

？
1、明白顶点坐标和纹理坐标的关系？（https://blog.csdn.net/xipiaoyouzi/article/details/53584798）
一直没有弄明白顶点坐标和纹理坐标的关系。几何坐标决定顶点在屏幕上绘制的位置，而纹理坐标决定纹理图像中的哪一个纹素赋予该顶点。

纹理坐标指的是贴图纹理的各个点，这些点分别和哪个顶点对应。

总结： 创建缓存数据并完成最终渲染显示的七个步骤

生成: glGenBuffers()
绑定缓存数据: glBindBuffer()
缓存数据:glBufferData()
启用:glEnableVertexAttribArray()
设置指针:glVertexAttribPointer()
绘图:glDrawArrays()
删除:glDeleteBuffers()

