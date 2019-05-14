# LearnOpenGL-05-Transform
<br/>

> 在开启本示例前，希望大家能先阅读这篇文章[变换](https://learnopengl-cn.github.io/01%20Getting%20started/07%20Transformations/)，主要是要先了解下**向量**和**矩阵**以及他们之间的计算，这有利于下面的示例。

<br/>

<br/>

环境配置---配置glm [mac xcode配置OpenGL](https://www.cnblogs.com/Anita9002/p/9143515.html)

<br/>


## 1 创建变换矩阵

### 1.1 初始化矩阵
通过`glm`库创建变换矩阵非常方便，关于`glm`库的配置，前面有给出链接，这边不再赘述。
直接看代码：
初始化一个`单位矩阵`
```
// 初始化一个4x4的单位向量
glm::mat4 transform = glm::mat4(1.0f);
```

### 1.2 变换矩阵
- 缩放：将矩阵缩放一半
```
transform = glm::scale(transform, glm::vec3(0.5f, 0.5f, 0.5f));
```
<br/>

- 位移：向右下角位移，x移动0.5f，y移动0.5f
```
transform = glm::translate(transform, glm::vec3(0.5f, -0.5f, 0.0f));
```
<br/>

- 旋转：按`z`轴进行旋转
```
// 这里将时间当作旋转的角度传递过去
transform = glm::rotate(transform, (float)glfwGetTime(), glm::vec3(0.0, 0.0f, 1.0f));
```

<br/>

## 2 变换矩阵传递给着色器

### 2.1 编写着色器
这里的`顶点着色器`在之前的基础上，添加了一个`矩阵属性（mat4）`，并且是`uniform`修饰的，全局属性，在渲染的时候进行赋值。
```
uniform mat4 transform;
```
在`顶点着色器`函数内部使用这个`矩阵变换-transform`，即，设置位置时进行使用：
```
gl_Position = transform * vec4(aPos, 1.0);
```

那么整个`顶点着色器`就是：
```
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec2 TexCoord;
out vec3 vertexColor;

uniform mat4 transform;

void main() {
gl_Position = transform * vec4(aPos, 1.0);
vertexColor = aColor;
// 让图片纹理一开始上下颠倒
//    TexCoord = vec2(aTexCoord.x, 1.0 - aTexCoord.y);
TexCoord = aTexCoord;
}

```

### 2.2 着色器赋值
创建好`变换矩阵`，编写好`顶点着色器`后，下一步就是在渲染的时候给`顶点着色器`传递这个`变换矩阵`。
即：拿到`变换矩阵`在程序中的位置，然后根据这个位置将其`变换矩阵`传递过去
```
// 拿到着色器中的transform --- 变换矩阵，将值赋值过去
unsigned int transformLoc = glGetUniformLocation(ourShader.ID, "transform");
glUniformMatrix4fv(transformLoc, 1, GL_FALSE, glm::value_ptr(transform));
```

<br/>

以上也就完成了变换，全部代码，请看，`main.cpp`文件
