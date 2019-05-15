# LearnOpenGL-07-Camera

<br/>

>  此示例学习资源来自于[LearnOpenGL](https://learnopengl-cn.github.io/)，感谢！建议在查看此示例前，先看看这篇文章[摄像机](https://learnopengl-cn.github.io/01%20Getting%20started/09%20Camera/)，先对坐标系统和各个空间有所了解。
<br/>


## 1 摄像机/观察空间
### 1.1 摄像机位置
获取摄像机位置很简单。摄像机位置简单来说就是世界空间中一个指向摄像机位置的向量。我们把摄像机位置设置为上一节中的那个相同的位置：
```
glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, -3.0f);
```

### 1.2 摄像机方向
下一个需要的向量是摄像机的方向，这里指的是摄像机指向哪个方向。现在我们让摄像机指向场景原点：(0, 0, 0)。还记得如果将两个矢量相减，我们就能得到这两个矢量的差吗？用场景原点向量减去摄像机位置向量的结果就是摄像机的指向向量。由于我们知道摄像机指向z轴负方向，但我们希望方向向量(Direction Vector)指向摄像机的z轴正方向。如果我们交换相减的顺序，我们就会获得一个指向摄像机正z轴方向的向量：
```
glm::vec3 cameraTarget = glm::vec3(0.0f, 0.0f, 0.0f);
glm::vec3 cameraDirection = glm::normalize(cameraPos - cameraTarget);
```

### 1.3 右轴
我们需要的另一个向量是一个右向量(Right Vector)，它代表摄像机空间的x轴的正方向。为获取右向量我们需要先使用一个小技巧：先定义一个上向量(Up Vector)。接下来把上向量和第二步得到的方向向量进行叉乘。两个向量叉乘的结果会同时垂直于两向量，因此我们会得到指向x轴正方向的那个向量（如果我们交换两个向量叉乘的顺序就会得到相反的指向x轴负方向的向量）：
```
glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f); 
glm::vec3 cameraRight = glm::normalize(glm::cross(up, cameraDirection));
```
### 1.4 上轴
现在我们已经有了x轴向量和z轴向量，获取一个指向摄像机的正y轴向量就相对简单了：我们把右向量和方向向量进行叉乘：

```
glm::vec3 cameraUp = glm::cross(cameraDirection, cameraRight);
```
<br/>

## 2 Look At
glm::LookAt函数需要一个位置、目标和上向量。它会创建一个和在上一节使用的一样的观察矩阵。
我们可以这样创建一个`LookAt矩阵`:
```
glm::mat4 view;
view = glm::lookAt(glm::vec3(0.0f, 0.0f, 3.0f), 
glm::vec3(0.0f, 0.0f, 0.0f), 
glm::vec3(0.0f, 1.0f, 0.0f));
```

我们为了有个更好玩的效果，这里会动态修改`相机的位置`达到选择的效果：
```
float radius = 10.0f;
float camX = sin(glfwGetTime()) * radius;
float camZ = cos(glfwGetTime()) * radius;
glm::mat4 view;
view = glm::lookAt(glm::vec3(camX, 0.0, camZ), glm::vec3(0.0, 0.0, 0.0), glm::vec3(0.0, 1.0, 0.0)); 
```
这里可以调整半径，将`相机的位置`拉的更远，就可以看得更全，比如将其设为30.0f
```
float radius = 30.0f;
```

以上运行项目，我们就能看到摄像机围绕着场景转了
<br/>
<br/>

## 3 自由移动
上个小示例是让摄像机围绕着场景旋转，这个小示例我们自己移动摄像机

- 观察矩阵调整
首先，定义好摄像机变量，全局的，这样方便后面修改
```
glm::vec3 cameraPos   = glm::vec3(0.0f, 0.0f,  3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp    = glm::vec3(0.0f, 1.0f,  0.0f);
```
这三个变量，分别是`位置向量`、`目标向量`和`上向量`
有了这三个变量就可以创建`观察矩阵`了---`LookAt矩阵`
```
view = glm::lookAt(cameraPos, cameraPos + cameraFront, cameraUp);
```
这段代码替换上一个小示例中设置`观察矩阵`的代码。

- 监听键盘，修改矩阵参数
变量和矩阵都设置好后，下面是通过键盘控制，我们这里是监听`WASD`键的任何一个，都会进行移动。
```
float cameraSpeed = 0.05f;
if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS) {
    cameraPos += cameraSpeed * cameraFront;
}
if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS) {
    cameraPos -= cameraSpeed * cameraFront;
}
if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS) {
    cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
}
if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS) {
    cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
}
```
`cameraSpeed`控制相机移动速度，可以修改值调整速度。
<br/>
<br/>

## 4 移动速度
上一个小示例我们将移动的速度控制在一个常量。但实际开发过程中会跟进设备处理器的能力不同调用processInput函数的频率不同，结果会需要移动的速度是可变的。

<br/>

图形程序和游戏通常会跟踪一个时间差(Deltatime)变量，它储存了渲染上一帧所用的时间。我们把所有速度都去乘以deltaTime值。结果就是，如果我们的deltaTime很大，就意味着上一帧的渲染花费了更多时间，所以这一帧的速度需要变得更高来平衡渲染所花去的时间。使用这种方法时，无论你的电脑快还是慢，摄像机的速度都会相应平衡，这样每个用户的体验就都一样了。

<br/>

我们跟踪两个全局变量来计算出deltaTime值：
```
float deltaTime = 0.0f; // 当前帧与上一帧的时间差
float lastFrame = 0.0f; // 上一帧的时间
```

在每一帧中我们计算出新的`deltaTime`
```
float currentFrame = glfwGetTime();
deltaTime = currentFrame - lastFrame;
lastFrame = currentFrame;
```

有了`deltaTime`后可以动态计算速度了
```
float cameraSpeed = 2.5f * deltaTime;
```
<br/>
<br/>

## 5 视角移动

### 5.1 欧拉角
#### 5.1.1 俯仰角的分量
```
direction.y = sin(glm::radians(pitch)); // 注意我们先把角度转为弧度
direction.x = cos(glm::radians(pitch));
direction.z = cos(glm::radians(pitch));
```
<br/>

#### 5.1.2 偏航角的分量
```
direction.x = cos(glm::radians(pitch)) * cos(glm::radians(yaw)); // 译注：direction代表摄像机的前轴(Front)，这个前轴是和本文第一幅图片的第二个摄像机的方向向量是相反的
direction.y = sin(glm::radians(pitch));
direction.z = cos(glm::radians(pitch)) * sin(glm::radians(yaw));
```
<br/>

### 5.2 鼠标输入

首先我们要告诉GLFW，它应该隐藏光标，并捕捉(Capture)它。
```
glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);
```
为了计算俯仰角和偏航角，我们需要让GLFW监听鼠标移动事件。（和键盘输入相似）我们会用一个回调函数来完成，函数的原型如下：
```
void mouse_callback(GLFWwindow* window, double xpos, double ypos);
```
这里的xpos和ypos代表当前鼠标的位置。当我们用GLFW注册了回调函数之后，鼠标一移动mouse_callback函数就会被调用：
```
glfwSetCursorPosCallback(window, mouse_callback);
```

在处理FPS风格摄像机的鼠标输入的时候，我们必须在最终获取方向向量之前做下面这几步：

- 计算鼠标距上一帧的偏移量。
- 把偏移量添加到摄像机的俯仰角和偏航角中。
- 对偏航角和俯仰角进行最大和最小值的限制。
- 计算方向向量。

#### 5.2.1 计算鼠标距上一帧的偏移量
第一步是计算鼠标自上一帧的偏移量。我们必须先在程序中储存上一帧的鼠标位置，我们把它的初始值设置为屏幕的中心（屏幕的尺寸是800x600）：
```
float lastX = 400, lastY = 300;
```

然后在鼠标的回调函数中我们计算当前帧和上一帧鼠标位置的偏移量：
```
float xoffset = xpos - lastX;
float yoffset = lastY - ypos; // 注意这里是相反的，因为y坐标是从底部往顶部依次增大的
lastX = xpos;
lastY = ypos;

float sensitivity = 0.05f;
xoffset *= sensitivity;
yoffset *= sensitivity;
```
注意我们把偏移量乘以了sensitivity（灵敏度）值。如果我们忽略这个值，鼠标移动就会太大了；你可以自己实验一下，找到适合自己的灵敏度值。

<br/>

#### 5.2.2 把偏移量添加到摄像机的俯仰角和偏航角中
接下来我们把偏移量加到全局变量pitch和yaw上：
```
yaw   += xoffset;
pitch += yoffset;
```
<br/>

#### 5.2.3 对偏航角和俯仰角进行最大和最小值的限制
第三步，我们需要给摄像机添加一些限制，这样摄像机就不会发生奇怪的移动了（这样也会避免一些奇怪的问题）。对于俯仰角，要让用户不能看向高于89度的地方（在90度时视角会发生逆转，所以我们把89度作为极限），同样也不允许小于-89度。这样能够保证用户只能看到天空或脚下，但是不能超越这个限制。我们可以在值超过限制的时候将其改为极限值来实现：
```
if(pitch > 89.0f)
    pitch =  89.0f;
if(pitch < -89.0f)
    pitch = -89.0f;
```
注意我们没有给偏航角设置限制，这是因为我们不希望限制用户的水平旋转。当然，给偏航角设置限制也很容易，如果你愿意可以自己实现。
<br/>

#### 5.2.4 计算方向向量
第四也是最后一步，就是通过俯仰角和偏航角来计算以得到真正的方向向量：
```
glm::vec3 front;
front.x = cos(glm::radians(pitch)) * cos(glm::radians(yaw));
front.y = sin(glm::radians(pitch));
front.z = cos(glm::radians(pitch)) * sin(glm::radians(yaw));
cameraFront = glm::normalize(front);
```

最后的代码应该是这样的：
```
/**
监听鼠标移动回调

@param window 窗口
@param xpos 移动到当前的x值
@param ypos 移动到当前的y值
*/
void mouse_callback(GLFWwindow* window, double xpos, double ypos) {

    // 控制第一次鼠标进入屏幕会闪动的问题
    if(firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    // 计算两次移动的偏移量
    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos;
    // 刷新上一次变动的值
    lastX = xpos;
    lastY = ypos;

    // 将偏移量进行灵敏度处理
    float sensitivity = 0.05;
    xoffset *= sensitivity;
    yoffset *= sensitivity;

    // 将偏移量放到全局角度变量上
    yaw   += xoffset;
    pitch += yoffset;

    // 角度最大值最小值限制
    if(pitch > 89.0f)
        pitch = 89.0f;
    if(pitch < -89.0f)
        pitch = -89.0f;

    // 通过俯仰角和偏航角计算真正的方向向量
    glm::vec3 front;
    front.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
    front.y = sin(glm::radians(pitch));
    front.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
    cameraFront = glm::normalize(front);
}
```
完成编辑后，运行项目，移动鼠标即可看到移动效果了。
<br/>
<br/>

## 6 缩放
我们使用鼠标的滚轮来实现缩放，和鼠标移动、键盘输入一样，我们需要一个鼠标滚轮的回调函数：
```
void scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
{
    if(fov >= 1.0f && fov <= 45.0f)
        fov -= yoffset;
    if(fov <= 1.0f)
        fov = 1.0f;
    if(fov >= 45.0f)
        fov = 45.0f;
}
```
当滚动鼠标滚轮的时候，yoffset值代表我们竖直滚动的大小。当scroll_callback函数被调用后，我们改变全局变量fov变量的内容。因为45.0f是默认的视野值，我们将会把缩放级别(Zoom Level)限制在1.0f到45.0f。

我们现在在每一帧都必须把透视投影矩阵上传到GPU，但现在使用fov变量作为它的视野：
```
projection = glm::perspective(glm::radians(fov), 800.0f / 600.0f, 0.1f, 100.0f);
```

最后不要忘记注册鼠标滚轮的回调函数：
```
glfwSetScrollCallback(window, scroll_callback);
```

以上。运行项目，查看效果吧。

<br/>
<br/>

## 摄像机类
最后我们封装一个摄像机类`Camera`，详见`Camera.hpp`文件。
`main.cpp`文件中的示例有使用这个类，具体的使用请看`Camera_Class`宏后面的代码。
