# LearnOpenGL-04-Texture

<br/>

>  此示例学习资源来自于[LearnOpenGL](https://learnopengl-cn.github.io/)，感谢！
<br/>


本篇示例主要介绍纹理-Texture。对于纹理，主要会介绍两部分，一部分是纹理的创建，一部分是纹理的使用（单纹理使用、多纹理使用）

## 纹理的坐标

### 纹理坐标
在开始之前，先简单介绍下纹理的坐标。
纹理坐标：用来标明该从纹理图像的哪个部分进行采样（采集片段颜色）
纹理坐标：在x和y轴上，范围是0-1之间（目前介绍的是2D纹理图像），即开始于（0，0）纹理图片的左下角，终止于（1，1）纹理图片的右上角。
如果我们设置一个三角形，那么他的纹理坐标可以是这样：
```
float texCoord[] = {
    0.0f, 0.0f, // 左下角
    1.0f, 0.0f, // 右下角
    0.5f, 1.0f  // 上中
}
```
本示例中，将纹理的坐标数据和顶点着色器的数据源放在了一起，都放在了`顶点数组对象`中了，后面在使用的时候告知下OpenGL怎么取即可。
```
// 顶点数据数组，包含纹理数据
// 纹理是2维数据，范围是(0,0)左下-(1,1)右上
float vertices[] = {

// points           // colors           // texture coords
0.5f,  0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   1.0f, 1.0f,// top right
0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   1.0f, 0.0f,// bottom right
-0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 0.0f,   0.0f, 0.0f, // bottom left
-0.5f,  0.5f, 0.0f, 1.0f, 1.0f, 0.0f,   0.0f, 1.0f   // top left
};
```
### 着色器
#### 顶点着色器
匹配纹理的着色器需要进行调整，首先是`顶点着色器`。
`顶点着色器`上添加纹理坐标的接受值`aTexCoord`，以及传递给`片段着色器`的输出值`TexCoord`。
```
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

void main()
{
gl_Position = vec4(aPos, 1.0);
ourColor = aColor;
TexCoord = aTexCoord;
}
```
#### 片段着色器
接下来就是`片段着色器`，需要一个接收`顶点着色器`传递过来的`纹理坐标`，这里是`TexCoord`
纹理的处理，除了有`纹理坐标`(采集那一刻的纹理图像)还需要有`纹理采样器`(如何采集纹理图像)。
GLSL有一个供纹理对象使用的内建数据类型，叫做采样器(Sampler)，它以纹理类型作为后缀，比如`sampler1D`、`sampler3D`，或在我们的例子中的`sampler2D`。我们可以简单声明一个`uniform sampler2D`把一个纹理添加到片段着色器中，稍后我们会把纹理赋值给这个`uniform`。
完整的`片段着色器`代码
```
#version 330 core
out vec4 FragColor;
in  vec3 vertexColor;
in  vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;
void main() {
// 只要纹理
//    FragColor = texture(texture1, TexCoord);
// 纹理与颜色结合
//    FragColor = texture(texture1, TexCoord) * vec4(vertexColor, 1.0);
// 多纹理组合, 第一个透明度80，第二个20
FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
}
```

### 数据读取
告知OpenGL怎么读取数据时：
```
// 告诉opengl如何读取数据
// 因为此次点的位置和颜色的位置在一个数组里，颜色紧随位置后面，因此步长为6
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)0);
// 以顶点位置0作为参数启用顶点属性
glEnableVertexAttribArray(0);

//
// 颜色属性 从1开始, 偏移量是3
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)(3 * sizeof(float)));
// 以顶点位置1作为参数启用顶点属性 --- 颜色
glEnableVertexAttribArray(1);

// 文理设置 从2开始, 偏移量是6
glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void *)(6 * sizeof(float)));
// 以顶点位置1作为参数启用顶点属性 --- 颜色
glEnableVertexAttribArray(2);
```
也就是在之前的示例中添加了纹理的读取规范，其他的不再详细赘述了。


## 纹理的创建
纹理的创建这里简单分了四部分：纹理的创建、绑定、设置纹理采样方式、加载图片数据到纹理中。

### 1、纹理的创建和绑定
`纹理`的创建和绑定和`着色器`的创建绑定一样简单明了。

```
// 0、定义纹理
unsigned int texture;
// 1、创建1个texture给 texture
glGenTextures(1, &texture);

// 2、绑定纹理
glBindTexture(GL_TEXTURE_2D, texture);
```
<br/>

### 2、设置纹理采样方式
纹理坐标是告诉该从哪里进行采样，关于具体怎么样采样，就需要另外告知OpenGL了。
#### 2.1 纹理环绕方式**
纹理坐标的范围是（0，0）到（1，1），如果超出了纹理坐标范围之外，该如何采集，这就涉及到`纹理环绕方式`了。
OpenGL提供了以下几种选择：
 - `GL_REPEAT`：对纹理的默认行为。重复纹理图像。
 - `GL_MIRRORED_REPEAT`:  和GL_REPEAT一样，但每次重复图片是镜像放置的。
 - `GL_CLAMP_TO_EDGE`:  纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐标的边缘，产生一种边缘被拉伸的效果。
 - `GL_CLAMP_TO_BORDER`: 超出的坐标为用户指定的边缘颜色。
 这几个选择都可以使用`glTexParameter*`函数对单独的一个纹理坐标轴进行色值（s、t(如果是使用3D纹理还有一个r)他们和x、y、z是等价的）。
 如这篇示例中使用的是第一个默认的
 ```
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
 ```

另外，如果我们选择了`GL_CLAMP_TO_BORDER`这项，我们还需要指定一个边缘的颜色。这时需要使用`glTexParameterfv`函数设置，如：
```
float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f };
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
```
不过在这个示例中没有体现。
<br/>

#### 2.2 设置纹理过滤
OpenGL需要知道，怎样将纹理像素映射到纹理坐标上。如果一个很大的物体但纹理的分辨率很低的时候，这时候就需要进行额外操作了，OpenGL提供了`纹理过滤`的选项来进行这样的操作。OpenGL提供了很多`纹理过滤`选项，但目前我们介绍两个（本示例中会使用的一个）。
- `GL_NEAREST`:（也叫邻近过滤，Nearest Neighbor Filtering）是OpenGL默认的纹理过滤方式。当设置为GL_NEAREST的时候，OpenGL会选择中心点最接近纹理坐标的那个像素。
- `GL_LINEAR`：也叫线性过滤，(Bi)linear Filtering）它会基于纹理坐标附近的纹理像素，计算出一个插值，近似出这些纹理像素之间的颜色。

`GL_NEAREST`会产生颗粒状的图案，我们能够清晰看到组成纹理的像素，而`GL_LINEAR`能够产生更平滑的图案，很难看出单个的纹理像素。`GL_LINEAR`可以产生更真实的输出，但有些开发者更喜欢8-bit风格，所以他们会用`GL_NEAREST`选项。


当进行放大(Magnify)和缩小(Minify)操作的时候可以设置纹理过滤的选项，比如你可以在纹理被缩小的时候使用邻近过滤，被放大时使用线性过滤。我们需要使用glTexParameter*函数为放大和缩小指定过滤方式。本示例中的设置是：
```
// 设置纹理过滤方式：GL_NEAREST和GL_LINEAR
// GL_LINEAR: 线性过滤，(Bi)linear Filtering）它会基于纹理坐标附近的纹理像素，计算出一个插值，近似出这些纹理像素之间的颜色。
// 邻近过滤，Nearest Neighbor Filtering 是OpenGL默认的纹理过滤方式。当设置为GL_NEAREST的时候，OpenGL会选择中心点最接近纹理坐标的那个像素。
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

#### 2.3 多级渐远纹理
关于`纹理过滤`还有一种`多级渐远纹理`的过滤方案设置。
简单来说就是一系列的纹理图像，后一个纹理图像是前一个的二分之一。多级渐远纹理背后的理念很简单：距观察者的距离超过一定的阈值，OpenGL会使用不同的多级渐远纹理，即最适合物体的距离的那个。由于距离远，解析度不高也不会被用户注意到。同时，多级渐远纹理另一加分之处是它的性能非常好。

这一部分的设置，OpenGL提供了一个函数`glGenerateMipmaps`，在创建完一个纹理后调用它OpenGL就会承担接下来的所有工作了。后面的教程中你会看到该如何使用它。
为了指定不同多级渐远纹理级别之间的过滤方式，你可以使用下面四个选项中的一个代替原有的过滤方式：

- `GL_NEAREST_MIPMAP_NEAREST`: 使用最邻近的多级渐远纹理来匹配像素大小，并使用邻近插值进行纹理采样
- `GL_LINEAR_MIPMAP_NEAREST`:  使用最邻近的多级渐远纹理级别，并使用线性插值进行采样
- `GL_NEAREST_MIPMAP_LINEAR`:  在两个最匹配像素大小的多级渐远纹理之间进行线性插值，使用邻近插值进行采样
- `GL_LINEAR_MIPMAP_LINEAR`:  在两个邻近的多级渐远纹理之间使用线性插值，并使用线性插值进行采样
像纹理过滤一样，我们可以使用glTexParameteri将过滤方式设置为前面四种提到的方法之一：
```
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

### 3 加载图片资源填充纹理
这里分为两个简单的步骤，一个是加载图片资源，另一个是将资源数据填充到纹理中。

#### 3.1 读取图片资源到数据中
这里用到了一个加载图片资源数据的库`stb_image.h`[下载地址](https://github.com/nothings/stb/blob/master/stb_image.h)。
它的引用这里简单说明下，因为它纯头文件库，所以在将他添加到工程中后，还需要另创建一个新的C++文件，并在头文件中引入它：
```
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
```
通过定义`STB_IMAGE_IMPLEMENTATION`，预处理器会修改头文件，让其只包含相关的函数定义源码，等于是将这个头文件变为一个 .cpp 文件了。现在只需要在你的程序中包含stb_image.h并编译就可以了。

这一步骤，看看文件夹`stb_image`下面的文件。
轮子造好后，引入头文件`stb_image.h`，在使用的地方添加以下代码即可：
```
int width, height, nrChannels;
// 这几个参数分别是图片资源路径、宽、高及像素通道获取值，最后一个填0即可
unsigned char *data = stbi_load("container.jpg", &width, &height, &nrChannels, 0);
```

#### 3.2 填充数据到纹理中
拿到图片数据后，我们即可填充到纹理中
```
if (data) {
// 第一个参数：纹理目标类型，这里是2D
// 第二个参数：为纹理指定多级渐远纹理的级别，如果你希望单独手动设置每个多级渐远纹理的级别的话。这里我们填0，也就是基本级别。
// 第三个参数：把纹理储存为何种格式, 这里是RGB或RGBA
// 第四、五个参数：设置最终的纹理的宽度和高度
// 第六个参数：应该总是被设为0（历史遗留的问题）
// 第七个参数：源图片的格式，RGB这里是
// 第八个参数：传入的图片数据类型，这里data是char数组（byte）
// 第九个参数：真正的图像数据
glTexImage2D(GL_TEXTURE_2D, 0, imageType == ImageType_RGB ? GL_RGB : GL_RGBA, width, height, 0, imageType == ImageType_RGB ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
// 为当前绑定的纹理自动生成所有需要的多级渐远纹理。
glGenerateMipmap(GL_TEXTURE_2D);
} else {
std::cout << "Failed to load texture" << std::endl;
}
```

### 贴上代码
说了那么多理论性的知识，现在直接上一段创建的完整代码
```
/**
创建纹理

@param imagePath 图片资源路径
@param imageType 图片资源格式：RGB或RGBA，目前支持这两个
@return 创建后的纹理
*/
unsigned int creatTexture(const char* imagePath, const ImageType imageType) {
    unsigned int texture;
    // 1、创建1个texture给 texture
    glGenTextures(1, &texture);

    // 2、绑定纹理
    glBindTexture(GL_TEXTURE_2D, texture);

    // 3、设置纹理样式
    // 3.1 设置纹理环绕方式，这里的S和T对应x,y坐标，如果3D则是STR对应xyz。
    // GL_REPEAT: 环绕方式，对纹理的默认行为。重复纹理图像。其他的还有：
    // GL_MIRRORED_REPEAT    和GL_REPEAT一样，但每次重复图片是镜像放置的。
    // GL_CLAMP_TO_EDGE    纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐标的边缘，产生一种边缘被拉伸的效果。
    // GL_CLAMP_TO_BORDER    超出的坐标为用户指定的边缘颜色。这个需要设置边缘颜色，float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f }; glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // 设置纹理过滤方式：GL_NEAREST和GL_LINEAR
    // GL_LINEAR: 线性过滤，(Bi)linear Filtering）它会基于纹理坐标附近的纹理像素，计算出一个插值，近似出这些纹理像素之间的颜色。
    // 邻近过滤，Nearest Neighbor Filtering 是OpenGL默认的纹理过滤方式。当设置为GL_NEAREST的时候，OpenGL会选择中心点最接近纹理坐标的那个像素。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // 加载图片，并附加到纹理上
    int width, height, nrChannels;
    stbi_set_flip_vertically_on_load(true);
    unsigned char *data = stbi_load(imagePath, &width, &height, &nrChannels, 0);
    if (data) {
        // 第一个参数：纹理目标类型，这里是2D
        // 第二个参数：为纹理指定多级渐远纹理的级别，如果你希望单独手动设置每个多级渐远纹理的级别的话。这里我们填0，也就是基本级别。
        // 第三个参数：把纹理储存为何种格式, 这里是RGB
        // 第四、五个参数：设置最终的纹理的宽度和高度
        // 第六个参数：应该总是被设为0（历史遗留的问题）
        // 第七个参数：源图片的格式，RGB这里是
        // 第八个参数：传入的图片数据类型，这里data是char数组（byte）
        // 第九个参数：真正的图像数据
        glTexImage2D(GL_TEXTURE_2D, 0, imageType == ImageType_RGB ? GL_RGB : GL_RGBA, width, height, 0, imageType == ImageType_RGB ? GL_RGB : GL_RGBA, GL_UNSIGNED_BYTE, data);
        // 为当前绑定的纹理自动生成所有需要的多级渐远纹理。
        glGenerateMipmap(GL_TEXTURE_2D);
    } else {
        std::cout << "Failed to load texture" << std::endl;
    }
    // 释放data
    stbi_image_free(data);
    return texture;
}

```

## 纹理的使用

### 单纹理的使用
- 片段着色器调整
单纹理使用时，我们在`片段着色器`源码内部打开
```
FragColor = texture(texture1, TexCoord);
```
或者打开
```
FragColor = texture(texture1, TexCoord) * vec4(vertexColor, 1.0);
```
- 渲染调整
然后在渲染循环里，即绑定顶点数组对象前，添加这句代码
```
// 绑定纹理
glBindTexture(GL_TEXTURE_2D, texture1);
```

运行工程，即可看到效果。


### 多纹理混合
这里我们创建了两个纹理，`texture1`和`texture2`。

- 片段着色器调整
在`片段着色器`中打开纹理组合那行代码
```
// 多纹理组合, 第一个透明度80，第二个20
FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
```
- 设置纹理采样器的位置值
```
// 设置采样器
// 在设置采样器之前先激活程序
ourShader.use();

// 设置片段着色器中两个纹理采样器得位置值, 第一个是0，第二是是1
glUniform1i(glGetUniformLocation(ourShader.ID, "texture1"), 0);
glUniform1i(glGetUniformLocation(ourShader.ID, "texture2"), 1);
// 或者使用这个设置
//    ourShader.setInt("texture1", 0);
//    ourShader.setInt("texture2", 1);

```

- 激活、绑定纹理
在渲染循环中激活并绑定纹理来进行纹理绘制
```
// 绘制纹理，这里激活的GL_TEXTUREX是和上面给纹理采样器设置位置值相互对应的
glActiveTexture(GL_TEXTURE0);
glBindTexture(GL_TEXTURE_2D, texture1);
glActiveTexture(GL_TEXTURE1);
glBindTexture(GL_TEXTURE_2D, texture2);
```

运行工程，即可看到效果。

- 补充：纹理单元
在上面我们已经见识过了`sample2D`修饰的`uniform`变量的时候，不需要用`glUniform`给它赋值，
而是使用`glUniform1i`给`纹理采样器`分配一个位置值，这样的话我们能够在一个片段着色器中设置多个纹理。
一个纹理的位置值通常称为一个`纹理单元(Texture Unit)`。一个纹理的默认纹理单元是0，它是默认的激活纹理单元，所以教程前面部分我们没有分配一个位置值。

纹理单元的主要目的是让我们在着色器中可以使用多于一个的纹理。通过把纹理单元赋值给采样器，我们可以一次绑定多个纹理，只要我们首先激活对应的纹理单元。就像glBindTexture一样，我们可以使用glActiveTexture激活纹理单元，传入我们需要使用的纹理单元：
```
glActiveTexture(GL_TEXTURE0);
glBindTexture(GL_TEXTURE_2D, texture1);
glActiveTexture(GL_TEXTURE1);
glBindTexture(GL_TEXTURE_2D, texture2);
```

参考资源：[纹理](https://learnopengl-cn.github.io/01%20Getting%20started/06%20Textures/)
