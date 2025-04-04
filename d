项目的层级结构如下
project-root/
├── bin/               # 存放最终可执行文件（已有）
├── build/            # 存放编译生成的中间文件（*.o）
├── include/          # 存放所有头文件（*.h）
├── src/              # 存放所有源代码文件（*.c）
│   ├── main.c       # main文件可保留在src根目录或子目录
│   └── module/      # 可选：按模块划分子目录
├── test/             # 可选：存放测试代码
├── doc/              # 可选：存放文档
└── Makefile

其中bin目录存放最终编译好的二进制文件
Build存放中间连接文件.o
include存放所有头文件
Test目录下的send.sh用来测试http数据包的解析

项目实现的思路
使用socket进行监听，使用epoll实现多路复用，减少资源消耗

http解析器

由于实际使用中请求的数量非常大，如果都进行解析的话性能开销比较大，所以使用这里我们先对数据包进行一个简单判断，符合http数据包的一些基本特征，则认为是http数据包，然后再开始对数据包进行解析。

对于http数据包的判断，主要是对数据包的第一行进行判断，按照格式
Method+空格+path+空格+HTTP/version
来判断，只要符合这个格式，就认为是http数据包。首先是method，http的协议就是那固定的几个名称，值判断第一个字符时候是G，P，D等等，如果不是则不是http数据包，如果是则进行下一步判断否存在空格，是否存在path，对于path，值判断第一个字符是\即可
只要上面任意一处不符合条件，则判断是非http数据包

判断结束以后，需要对http数据包进行下一步处理，http的格式基本固定，并且有确定的字符对其进行分割，比较适合使用状态机来实现。
使用START,METHOD,PATH,......,DONE,ERROR分别表示当前不同的状态，对传入的http数据逐字符进行解析。当碰到对应的分割字符时，需要将当前的字段进行记录，然后跳转到下一字段。这里使用两个int变量来实现，mark记录当前状态最开始的字符的下标，pos记录当前字符的下表，等到状态变化时，提取出两个下标之间的字符串即可。
为了较少复制次数，实现零拷贝，使用char*来记录当前的字段字符的起始位置mark的地址，使用len来记录当前字段的长度，pos-mark。所以字段的结构体应该时
typedef struct {
    const char* data;
    int len;
} string_view_t;

状态机实现是由结构体组成，每一次解析都需要malloc，为了减少malloc的次数，只在最开始进行空间分配，后续的解析器都是使用同一个，每次使用前将数据清空即可。

文件保存
文件保存分为两种情况，一种是使用保存解析后的http数据，一种是解析保存原始数据的hex形式


数据读取
数据读取使用read函数，read在调用的时候需要确定读取的大小，对于socket传入的数据长度是不固定的，read可能一次读取不完，又由于设置了边缘触发，没有读取到的数据可能就会被覆盖。为了完整的读取长数据，这里使用动态缓冲区的机制，然后循环调用read读取内核数据，并将读取的数据追加到缓冲区中，如果缓冲区
