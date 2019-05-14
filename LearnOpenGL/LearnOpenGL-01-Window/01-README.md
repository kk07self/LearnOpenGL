# LearnOpenGL-01-Window

>  此示例学习资源来自于[LearnOpenGL](https://learnopengl-cn.github.io/)，感谢！

## 第一个示例：窗口

显示一个窗口的步骤：
- 1、初始化glfw并用其创建一个window窗口
    - 这里一是初始化glfw并设置其信息
    - 通过glfw创建窗口
    - 监察是否创建成功
    
```c++
// 初始化glfw，并配置信息
glfwInit();
// 主板版本号
glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
// 次版本号
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
// 使用的是核心模式(Core-profile)
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
// Mac OS X系统需要设置
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif
// 创建一个窗口
GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL", NULL, NULL);
if (window == NULL)
{
std::cout << "Failed to create GLFW window" << std::endl;
glfwTerminate();
return -1;
}
```

- 2、配置窗口信息
    - 这里主要是将创建的窗口设置成上下文
    - 配置窗口大小调整的函数
    - 用glad统一管理OpenGL的函数指针，因此初始化glad
    
```c++
// 将我们窗口的上下文设置为当前线程的主上下文
glfwMakeContextCurrent(window);

// 注册窗口大小调整函数，每次调整回调都会调用callback的方法
glfwSetFramebufferSizeCallback(window, frameBuffer_size_callback);

// glad: load all OpenGL function pointers
// glad: 管理OpenGL的函数指针，在OpenGL函数使用之前初始化glad
if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
std::cout << "Failed to initialize GLAD" << std::endl;
return -1;
}
```

- 3、循环渲染
    - 循环渲染的条件：如果没有点击点击**esc**键就保持渲染，否则关闭窗口渲染
    - 渲染分为两个部分：一是状态设置、二是使用设置的状态，这里只是简单设置了颜色
    - 交换缓冲+监听触发的事件

```c++
// glfw: swap buffers and poll IO events (keys pressed/released, mouse moved etc.)
// 会交换颜色缓冲（它是一个储存着GLFW窗口每一个像素颜色值的大缓冲），它在这一迭代中被用来绘制，并且将会作为输出显示在屏幕上。
glfwSwapBuffers(window);

// 检查有没有触发什么事件（比如键盘输入、鼠标移动等）、更新窗口状态，并调用对应的回调函数（可以通过回调方法手动设置）
glfwPollEvents();
```

- 4、在所有结束后清除缓冲
```c++
// 释放资源
glfwTerminate();
```
