# OpenGL_NK
OpenGL 是在三维坐标系上绘制
c语言编译流程：预编译、编译、汇编、链接
glsl的编译过程类似c语言，主要有glCompileShader、glAttachShader、glLinkProgram三步

1、运行之后看不到效果

GLuint projectionMatrixSlot = glGetUniformLocation(self.myProgram, "projectionMatrix");
GLuint modelViewMatrixSlot = glGetUniformLocation(self.myProgram, "modelViewMatrix");

写成了glGetAttribLocation函数
