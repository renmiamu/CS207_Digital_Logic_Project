# CS207 2024 Fall Project：Kitchen Exhaust Hood

**小组成员**：沈泓立、郑袭明、刘安钊

## 开发日程安排和实施情况

### 1.团队分工及贡献占比

**沈泓立**: 开关机实现、手势开关实现（bonus）以及时间调整、照明功能、开机时间显示以及调整、项目文档编写

**郑袭明**: 累计工作时间显示、智能提醒时间显示以及调整、蜂鸣器（bonus）输出智能提醒及工作档位、项目文档编写

**刘安钊**: 模式切换功能实现、飓风模式和自清洁模式倒计时、手势开关部分实现、项目文档编写

**贡献百分比**: 1:1:1

### 2.开发计划日程安排

```
第十周：任务分工
第十一周：开机功能、模式切换、抽油烟机功能基础、照明功能、自清洁功能
第十二周：计时功能、智能提醒、高级设置、查询功能
第十三周：附加分
第十四周：功能合并、测试
第十五周：答辩
```

### 3.实施情况

```
第十周：任务分工
第十一周：模式切换、自清洁功能、开关机功能、开机时间显示以及调整
第十二周：飓风模式相关逻辑实现、手势开关初步、照明功能、智能提醒、累计工作时间显示
第十三周：手势开关、智能提醒时间设置
第十四周：蜂鸣器实现提醒与档位输出、功能合并、测试
第十五周：答辩
第十六周：项目文档编写
第十七周：项目文档编写
```

### 4.心得

由于各组员学习任务较重，小组采用分工进行模块化编程的方式逐步实现了整个项目，并且时间整体较为充裕。经过整个项目的编写，我们小组对于硬件语言有了更加充分的了解，为日后的计算机专业学习打下了坚实的基础。

## 系统功能列表和使用说明

**本项目实现了一个由EGO1控制的抽油烟机，并具有以下功能：**

1.短按开机键开机，长按关机键（同开机键）3秒实现关机。

2.先按左键开始5秒（可切换为2秒、7秒、9秒）倒计时，在5秒（2秒、7秒、9秒）内按右键实现开机；关机操作反之。若未完成后半部分则失效。

3.待机模式下按下菜单键后可通过按下档位键进入三个档位或自清洁模式，开机后只能使用一次飓风模式，飓风模式运行60秒后自动返回二档，在这60秒中如果按下菜单键则经过60秒倒计时强制返回待机模式。进入三个档位后会开始累计工作时间，达到提醒时长（默认10h）后，在待机模式会进行提醒。

**显示模块**包括led灯的显示（开机、档位、照明、自清洁）、七段数码管的显示（开机时间、累计工作时间、手势操作时间、提醒时间）

**输入输出端口说明示意图**如下：

![EGO1](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/EGO1.png)

**顶层端口设计**如下：

|      Port name       | Direction |   Type    |      Description       |
| :------------------: | :-------: | :-------: | :--------------------: |
|        reset         |   input   |           |        重置系统        |
|         clk          |   input   |           |       总时钟信号       |
|      key_input       |   input   |   wire    |        开关机键        |
|     time_select      |   input   | wire[1:0] |    手势操作时间设置    |
|       left_key       |   input   |   wire    |      手势操作左键      |
|      right_key       |   input   |   wire    |      手势操作右键      |
|  power_control_mode  |   input   |   wire    |      开机模式切换      |
|       set_mode       |   input   |   wire    |      时间设置模式      |
|      set_select      |   input   |   wire    |   时间设置小时或分钟   |
|     increase_key     |   input   |   wire    |    开机时间增加按键    |
| increase_warning_key |   input   |   wire    |    提醒时间增加按键    |
|      light_key       |   input   |   wire    |        照明开关        |
|       menu_btn       |   input   |   wire    |         菜单键         |
|      speed_btn       |   input   | wire[2:0] |        工作档位        |
|      clean_btn       |   input   |   wire    |        清洁按钮        |
|     display_mode     |   input   |   wire    | 显示工作时间或提醒时间 |
|    work_time_key     |   input   |   wire    |      工作时间切换      |
|   gesture_time_key   |   input   |   wire    |  手势操作时间切换按钮  |
|     power_state      |  output   |    reg    |         开机灯         |
|    tub_segments1     |  output   |   [7:0]   |  第一组七段数码管内容  |
|    tub_segments2     |  output   |   [7:0]   |  第二组七段数码管内容  |
|  tub_segment_select  |  output   |   [7:0]   |     七段数码管控制     |
|     light_state      |  output   |   wire    |         照明灯         |
|         mode         |  output   |   [2:0]   |        工作模式        |
|      countdown       |  output   |   wire    |      倒计时显示灯      |
|       reminder       |  output   |   wire    |       提醒清洁灯       |
|       speaker        |  output   |   wire    |         扬声器         |
|         pwm          |  output   |   wire    |        pwm信号         |



并可以用下图展示：

![main](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/main.png)

## 系统结构说明

**本项目的结构可由下面的流程图说明，其中，每个模块的功能在后面的子模块功能说明中有详细的介绍。**

## 子模块功能说明

### 顶层模块：main

![Schematic](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/Schematic1.png)

![Schematic2](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/Schematic2.png)

内部直接实现子模块实例：

​	`gesture_power_control`，实现手势操作的核心逻辑。

​	`key_press_detector`，检测为短按还是3秒长按。

​	`power_control`，短按开机，长按关机实现。

​	`timer_mode`，开机时间显示以及调整。

​	`light`，照明功能。

​	`mode_change`，

​	`sound_reminder`，

### 子模块：gesture_power_control_timer

这段代码实现了手势控制定时器模块，根据输入的时间选择信号（`tub_select`），设置不同的倒计时时间，并控制数码管显示相应的数字，同时通过`tub_select_gesture_time`信号选择数码管的显示。

![gesture_power_control_timer](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/gesture_power_control_timer.png)

|         Port name         | Direction |  Type  |  Description   |
| :-----------------------: | :-------: | :----: | :------------: |
|           reset           |   input   |        |      重置      |
|            clk            |   input   |        |    时钟信号    |
|        time_select        |   input   | [1:0]  |  时间选择信号  |
|      countdown_time       |  output   | [31:0] |   倒计时时间   |
| tub_segments_gesture_time |  output   | [7:0]  | 七段数码管内容 |
|  tub_select_gesture_time  |  output   |        | 七段数码管控制 |



### 子模块：gesture_power_control

这段代码实现了手势控制电源管理模块，根据左右键输入和倒计时状态切换不同的工作模式，通过控制倒计时和电源状态（开/关），以及与手势时间选择模块配合，更新数码管内容。

内部实现了**子模块**`gesture_power_control_timer`，控制倒计时时间和数码管显示。

![gesture_power_control](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/gesture_power_control.png)

|         Port name         | Direction | Type  |  Description   |
| :-----------------------: | :-------: | :---: | :------------: |
|           reset           |   input   |       |      重置      |
|            clk            |   input   |       |    时钟信号    |
|         left_key          |   input   |       |  手势开关左键  |
|         right_key         |   input   |       |  手势开关右键  |
|        time_select        |   input   | [1:0] |  时间选择信号  |
|        power_state        |  output   |  reg  |    电源信号    |
| tub_segments_gesture_time |  output   | [7:0] | 七段数码管信号 |
|  tub_select_gesture_time  |  output   |       | 七段数码管控制 |



### 子模块：key_press_detector

这段代码实现了一个按键按下检测模块，通过计数按键按下的持续时间，区分短按和长按事件，并根据按键输入生成相应的`short_press`和`long_press`信号。

![key_press_detector](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/key_press_detector.png)

|  Port name  | Direction | Type | Description  |
| :---------: | :-------: | :--: | :----------: |
|    reset    |   input   |      |     重置     |
|     clk     |   input   |      |   时钟信号   |
|  key_input  |   input   |      | 按键输入信号 |
| short_press |  output   | reg  |   短按信号   |
| long_press  |  output   | reg  |   长按信号   |



### 子模块：power_control

这段代码实现了一个电源控制模块，通过检测短按和长按事件来切换电源状态（开/关）。在系统复位时，电源默认为关闭状态；短按事件会将电源打开，长按事件则会将电源关闭。

![power_control](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/power_control.png)

|  Port name  | Direction | Type | Description |
| :---------: | :-------: | :--: | :---------: |
|    reset    |   input   |      |    重置     |
|     clk     |   input   |      |  时钟信号   |
| short_press |   input   |      |  短按信号   |
| long_press  |   input   |      |  长按信号   |
| power_state |  output   | reg  |  电源信号   |



### 子模块：timer_mode

这段代码实现了一个定时器模块，能够显示并设置当前时间（小时、分钟、秒），并支持通过按键调整时间，同时动态扫描数码管显示和处理按键去抖及持续按键逻辑。

![timer_mode](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/timer_mode.png)

|   Port name    | Direction | Type  |     Description      |
| :------------: | :-------: | :---: | :------------------: |
|     reset      |   input   |       |         重置         |
|      clk       |   input   |       |       时钟信号       |
|  power_state   |   input   |       |       电源信号       |
|    set_mode    |   input   |       |     设置时间模式     |
|   set_select   |   input   |       |  设置小时或分钟信号  |
|  Increase_key  |   input   |       |     时间增加按键     |
| tub_segments_1 |  output   | [7:0] | 第一组七段数码管显示 |
| tub_segments_2 |  output   | [7:0] | 第二组七段数码管显示 |
|   tub_select   |  output   | [5:0] |    七段数码管控制    |



### 子模块：light

这段代码实现了一个灯光控制模块，通过检测light_key按键的状态变化，控制灯光的开关（light_state）,并根据电源状态（power_state）判断是否允许控制灯光。

![light](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/light.png)

|  Port name  | Direction | Type | Description |
| :---------: | :-------: | :--: | :---------: |
|    reset    |   input   |      |    重置     |
|     clk     |   input   |      |  时钟信号   |
| power_state |   input   |      |  电源信号   |
|  light_key  |   input   |      |  照明按键   |
| light_state |  output   | reg  |  照明信号   |



### 子模块：mode_change

这段代码实现了一个模式切换模块，通过状态机实现多种工作模式的切换，如三种工作挡位之间的切换、自清洁、工作时间累计、智能提醒等功能。模块通过数码管显示工作时间或提醒时间，并能够调整智能提醒时间。

![](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/mode_change.png)

|     Port name     | Direction | Type  |    Description     |
| :---------------: | :-------: | :---: | :----------------: |
|       reset       |   input   |       |        重置        |
|        clk        |   input   |       |      时钟信号      |
|     menu_btn      |   input   |       |       菜单键       |
|     speed_btn     |   input   | [2:0] |      工作挡位      |
|     clean_btn     |   input   |       |     自清洁按键     |
|     set_mode      |   input   |       |    时间选择信号    |
|   display_mode    |   input   |       |  累计工作时间显示  |
|    set_select     |   input   |       | 设置小时或分钟信号 |
|   increase_key    |   input   |       |    时间增加按键    |
|    power_state    |   input   |       |      电源信号      |
|       mode        |  output   | [2:0] |      模式输出      |
|     countdown     |  output   |       |   倒计时输出信号   |
| cleaning_reminder |  output   |       |   自清洁提醒信号   |
|  tub_segments_1   |  output   | [7:0] |   七段数码管信号   |
|  tub_segments_2   |  output   | [7:0] |   七段数码管信号   |
|    tub_select     |  output   | [7:0] |   七段数码管控制   |



### 子模块：sound_reminder

这段代码实现了一个音频提醒模块，其主要功能是根据输入的使能信号 (`cleaning_reminder`) 和挡位输入 (`suction`)，生成一个 PWM 信号输出到扬声器 (`speaker`)，用以播放不同频率的声音，从而体现不同工作挡位。

![](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/sound_reminder.png)

|     Port name     | Direction | Type  | Description |
| :---------------: | :-------: | :---: | :---------: |
|        clk        |   input   |       |  时钟信号   |
| cleaning_reminder |   input   |       |  提醒信号   |
|      suction      |   input   | [2:0] |  挡位输入   |
|      speaker      |  output   | wire  |  声音信号   |



### 子模块：time_setter

这段代码实现了一个时间调整模块，其主要功能是通过 `increase_key` 按键输入调整当前时间的小时和分钟，并通过数码管显示小时和分钟，用户可以在设置模式下调整智能提醒时间。

![](https://github.com/renmiamu/CS207_Digital_Logic_Project/blob/master/photos/time_setter.png)

|   Port name    | Direction | Type  |     Description      |
| :------------: | :-------: | :---: | :------------------: |
|     reset      |   input   |       |         重置         |
|      clk       |   input   |       |       时钟信号       |
|    visible     |   input   |       |  控制数码管是否显示  |
|    set_mode    |   input   |       |     设置时间模式     |
|   set_select   |   input   |       |  设置小时或分钟信号  |
|  Increase_key  |   input   |       |     时间增加按键     |
| tub_segments_1 |  output   | [7:0] | 第一组七段数码管显示 |
| tub_segments_2 |  output   | [7:0] | 第二组七段数码管显示 |
|   tub_select   |  output   | [5:0] |    七段数码管控制    |



## Bonus实现说明

### 手势操作模式

手势操作通过两个模块协同实现，其中`gesture_power_control_timer`提供倒计时选择功能，能根据`time_select`输入生成不同的倒计时时间（默认5s，可调整为2s，7s，9s），并输出对应的数码管段码和使能信号用于显示；`gesture_power_control`是核心控制模块，采用**状态机**设计，分为空闲（`IDLE`）、左键等待（`LEFT_WAIT`）和右键等待（`RIGHT_WAIT`）三种状态，通过左右键输入实现电源的开关控制。当电源关闭时，按下左键进入倒计时等待状态，如果在倒计时结束前按下右键，电源开启；当电源开启时，按下右键进入倒计时等待状态，如果在倒计时结束前按下左键，电源关闭。

### 外接输出设备（扬声器）

外接扬声器能实现两个功能，分别为声音实现智能提醒和使用不同声音输出输出三种工作挡位。该功能通过两个模块协同实现，其中`mode_change`模块中输出当前工作的`mode`和`cleaning_reminder`，表示当前工作挡位及是否需要开启智能提醒。而在`sound_reminder`模块中，定义了四个参数`note`，`first`，`second`，`third`，分别为智能提醒和三种挡位对应的声音频率。根据输入的当前工作挡位`suction`和智能提醒信号`cleaning_reminder`，该模块中的多路选择器Mux会选择对应的声音频率进行输出。根据所选中的声音频率，模块会生成一个方波PWM信号，作为FPGA的低通滤波器的输入信号，低通滤波器将输入的数字信号转化为模拟电压信号输出到音频插孔上，从而给用户提供不同工作状态下的音频提示。

## 项目总结

### 遇到的一些问题和解决方案

1.在合并代码过程中，曾出现数码管显示时间无法切换或切换后时间冻结的问题。为解决此问题，最终通过增加一个专用按键，用于独立控制数码管的显示状态，使数码管显示功能与时间切换逻辑解耦。

2.在实现逻辑中，曾出现对于3档只能使用一次的限制条件，错误地基于 reset 信号进行判断，导致在每次系统复位后重置限制条件，而未能满足要求：限制条件应基于每次开机（电源开启）后才重置。为解决这一问题，最终通过增加条件判断逻辑，结合电源状态信号 power_state，在每次开机时将3档使用状态归零，而与 reset 信号无关。

### 远期优化

1.在工作模式状态下，暂时无法实现通过按关机键实现强制关机，可以继续完善该功能。

2.普通开关机模式和手势操作开关机模式存在记忆按键操作的现象，导致切换开关机模式时可能直接出发开机或关机，可以继续优化。

3.可以增加显示器外界输出，实现更加直观的外界输出。

4.可以增加电脑键盘操作档位调整的外界输入，实现操作更加方便快捷。

### 心得

在本学期抽油烟机项目的开发过程中，我们小组成员对Verilog这门全新的硬件描述语言有了更加直观而深入的理解，同时也切身体会到了将代码转化为实际可见成果所带来的成就感和满足感。这次项目实施过程中，小组分工明确，团队合作高效，没有出现任何偷懒或消极参与的情况，每位成员都为项目的顺利完成贡献了自己的力量。

感谢老师和助教的辛勤付出，你们的教学让我们受益匪浅。

## 对project的想法与建议

