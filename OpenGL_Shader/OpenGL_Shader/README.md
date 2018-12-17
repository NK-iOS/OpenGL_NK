# OpenGL_NK
OpenGL 是在三维坐标系上绘制

1、自定义着色器
出现的问题：
1> 对GLSL语言不熟（https://www.tuicool.com/articles/yEBFvmA）
    矩阵旋转（https://www.cnblogs.com/luweimy/p/4121789.html）
顶点着色器：处理顶点
片段着色器：处理像素点颜色
这部分有点麻烦，犯了好几个错误
2> glsl的编译过程类似c语言，主要有glCompileShader、glAttachShader、glLinkProgram三步

3> GLSL能做什么？

日以逼真的材质 -- 金属，岩石，木头，油漆等
日益逼真的光照效果 -- 区域光和软阴影
非现实材质 -- 美术效果，钢笔画，水墨画和对插画技术的模拟
针对纹理内存的新用途
更少的纹理访问
图形处理 -- 选择，边缘钝化遮蔽和复杂混合
动画效果 -- 关键帧插值，粒子系统
用户可编程的反走样方法
4> GLSL注意

GLSL支持函数重载
GLSL不存在数据类型的自动提升，类型必须严格保持一致。
GLSL不支持指针，字符串，字符，它基本上是一种处理数字数据的语言
GLSL不支持联合、枚举类型、结构体位字段及按位运算符


---------------
.vsh
// 顶点着色器
attribute vec4 postion;
/*
attribute限定符标记的是一种全局变量，该变量在顶点着色器中是只读（read-only）的,
该变量被用作从OpenGL程序向顶点着色器传递参数，因此该限定符仅能用于顶点着色器。
*/
attribute vec2 textCoordinate;
/*
uniform限定符标记的是一种全局变量，该变量对于一个图元来说是不可更改的，
它可以从OpenGL程序中接收传递来的参数。
mat4 声明四维浮点型矩阵
*/
uniform mat4 rotateMatrix;

/*
varying提供从顶点着色器向片段着色器传递数据方法，varying限定符可以在顶点着色器中定义变量，
然后再传递给光栅化器，光栅化器对数据插值后，再将每个片段的值交给片段着色器
*/
varying lowp vec2 varyTextCoord;

void main()
{
varyTextCoord = textCoordinate;

vec4 vPos = position;

vPos = vPos * rotateMatrix;

gl_Position = vPos;
}

.fsh
// 片段着色器
varying lowp vec2 varyTextCoord;

// sampler2D 访问一个二维纹理
uniform sampler2D colorMap;

void main()
{
gl_FragColor = texture2D(colorMap, varyTextCoord);
}

