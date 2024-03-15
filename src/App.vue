<template >
  <div style="display: flex;">
    <div class="parent-container mt-3" style="flex: 1.5; display: flex; justify-content: center; ">
      <div class="scrollable-content" >
      <table class="messagea" style=" border-collapse: separate;">
        <thead class="sticky-headera">
          <tr >
            <th class="noa " style="background-color: aquamarine;">序号</th>
            <th class="test" style="background-color: aquamarine;">发送方IP</th>
            <th class="test" style="background-color: aquamarine;">接收方IP</th>
            <th class="noa" style="background-color: aquamarine;">协议</th>
            <th class="noa" style="background-color: aquamarine;">长度</th>
            <th class="infoa" style="background-color: aquamarine;">信息</th>
          </tr>
        </thead>
        <tbody v-for="(packet, index) in dataList" :key="index">
          <!-- {{ packet }} -->
          <tr  v-if="packet['arp_layer']"  class="hover-effect"  @contextmenu="handleRightClick($event,packet)" @click="toggleDetails(index)" >
            <td class="noa">{{index+1}}</td>
            <td class="test">{{ packet['arp_layer']['protocol_source'] }}</td>
            <td class="test">{{ packet['arp_layer']['protocol_dest'] }}</td>
            <td class="noa">ARP</td>
            <td class="noa">{{ packet['arp_layer']['hardware_length'] +20}}</td>
            <td class="infoa">{{ packet['info'] }} </td>
          </tr>
          <tr  v-else :class="getColor(packet['ip_layer']['protocol'])" class="hover-effect" @contextmenu="handleRightClick($event,packet)" @click="toggleDetails(index)" >
            <td class="noa">{{index+1}}</td>
            <td class="test">{{ packet['ip_layer']['source_ip'] }}</td>
            <td class="test">{{ packet['ip_layer']['destination_ip'] }}</td>
            <td class="noa">{{ getProtocolName(packet) }}</td>
            <td class="noa">{{ packet['ip_layer']['total_length'] +20}}</td>
            <td class="infoa">{{ packet['info'] }} </td>
          </tr>
          <tr v-if="expandedIndex === index" >
            <td colspan="6" class="card-body detailsa left-align">
              <template v-for="(fields, keyName) in packetKeys" :key="keyName" class="mb-3 newtest" style="background-color:beige display: flex; align-items: center;">
                  <p v-if="packet[keyName] && keyName === 'ethernet_layer'" class="newtest hover-effect"  @click="toggleDetailsKey(keyName)">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src: {{ packet[keyName]['source_mac'] }}&nbsp;&nbsp; Dst: {{ packet[keyName]['destination_mac'] }}</p>
                  <p v-if="packet['ip_layer'] &&  keyName === 'ip_layer'" class="newtest hover-effect"  @click="toggleDetailsKey(keyName)">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src: {{ packet[keyName]['source_ip'] }}&nbsp;&nbsp; Dst: {{ packet[keyName]['destination_ip'] }}</p>
                  <p v-if="packet['tcp_layer'] &&  keyName === 'tcp_layer'" class="newtest hover-effect"  @click="toggleDetailsKey(keyName)"> &nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src Port: &nbsp;{{ packet[keyName]['source_port'] }}&nbsp;&nbsp; Dst Port: &nbsp;{{ packet[keyName]['destination_port'] }}&nbsp;&nbsp;&nbsp;&nbsp;Seq:&nbsp;{{ packet[keyName]['sequence_number'] }}&nbsp;&nbsp;&nbsp;&nbsp;Ack:&nbsp;{{ packet[keyName]['acknowledgment_number'] }}</p>
                  <p v-if="packet['arp_layer'] &&  keyName === 'arp_layer'" class="newtest hover-effect"  @click="toggleDetailsKey(keyName)">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src: {{ packet[keyName]['protocol_source'] }}&nbsp;&nbsp; Dst: {{ packet[keyName]['protocol_dest'] }}</p>
                  <p v-if="packet['icmp_layer'] &&  keyName === 'icmp_layer'" class="newtest hover-effect"  @click="toggleDetailsKey(keyName)">&nbsp;&nbsp;{{ keyName }}</p>
                  <p v-if="packet['udp_layer'] &&  keyName === 'udp_layer'" class="newtest hover-effect"  @click="toggleDetailsKey(keyName)">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src Port: &nbsp;{{ packet[keyName]['source_port'] }}&nbsp;&nbsp; Dst Port: &nbsp;{{ packet[keyName]['destination_port'] }}</p>
                <div v-if="expandedKey === keyName" class="card-body" >
                  <div v-for="field in fields" :key="field" class="active newtest hover-effect">
                    <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{{ field }}:&nbsp;&nbsp;{{packet[keyName][field]}}</p>
                  </div>
                </div>
              </template>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    </div>
    <div style="flex: 1; display: flex; flex-direction: column;" class="button-container">
    <!-- 第一个按钮 -->
    <div style="flex: 1; display: flex; align-items: center; justify-content: center; ">

      <button :class="{ 'green-button': isClicked }" class="custom-button large-button"  @click="toggleButtonClick()">{{ buttonText }}</button>
      <!-- 第二个按钮 -->
      <button class="custom-button large-button" @click="downloadFile" style="background-color: #3b90ff">保存数据</button>

      
      <button class="custom-button large-button" @click="submitFile" style="background-color: yellowgreen"><input ref="fileInput" type="file" @change="handleFileUpload"></button>
  </div>
  <div style="flex: 1; " class="input-container">
    <form >
      <div class="mb-3 row mxa">
        <label for="localIP" class="col-sm-2 col-form-label">本机IP</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" id="localIP" placeholder="请输入本机IP" />
        </div>
      </div>
      <div class="mb-3 row mxa">
        <label for="localMAC" class="col-sm-2 col-form-label">本机MAC</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" id="localMAC" placeholder="请输入本机MAC" />
        </div>
      </div>
      <div class="mb-3 row mxa">
        <label for="targetIP" class="col-sm-2 col-form-label">被攻击IP</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" id="targetIP" placeholder="请输入被攻击IP" />
        </div>
      </div>
      <div class="mb-3 row mxa">
        <label for="targetMAC" class="col-sm-2 col-form-label">被攻击MAC</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" id="targetMAC" placeholder="请输入被攻击MAC" />
        </div>
      </div>
      <div class="mb-3 row mxa">
        <label for="attackSeconds" class="col-sm-2 col-form-label">攻击秒数</label>
        <div class="col-sm-5">
          <input type="text" class="form-control" id="attackSeconds" placeholder="请输入攻击秒数" />
        </div>
      </div>
      <div class="d-grid col-sm-5 mxa mxb">
        <button class="btn btn-primary mxb" type="button" @click="submitAttack()">提交</button>
        <button class="btn btn-secondary mxb" type="button">取消</button>
      </div>
    </form>
  </div>

  </div>
</div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const file = ref(null);
const dataList = ref([]) // 用于存储从后端接收的数据
const expandedIndex = ref(-1) // 用于跟踪哪个条状的详细数据被展开
const expandedKey = ref('')
let socket
const packetKeys = {
  'ethernet_layer': ['source_mac', 'destination_mac', 'ethernet_type'],
  'ip_layer': ['source_ip', 'destination_ip', 'ip_version', 'header_length', 'tos', 'total_length', 'ip_flags', 'identification', 'fragment_offset', 'ttl', 'protocol', 'header_checksum'],
  'tcp_layer': ['source_port', 'destination_port', 'sequence_number', 'acknowledgment_number', 'tcp_flags', 'window_size', 'checksum', 'urgent_pointer'],
  'arp_layer':["hardware_type","protocol_type","hardware_length","protocol_length","hardware_source","protocol_source","hardware_dest","protocol_dest"],
  'icmp_layer':[ "type","code","checksum","identifier","sequence"],
  'udp_layer':["source_port","destination_port","length","checksum"]
}

const isClicked = ref(false);
const buttonText = ref('开始抓包');

const toggleButtonClick = async () => {
  isClicked.value = !isClicked.value;
  if (isClicked.value) {
    startPacketCaptureAnimation(); // 开始动画
    await fetchData(); // 获取数据
  } else {
    stopPacketCaptureAnimation(); // 停止动画
    await stopWebSocket(); // 停止 WebSocket 连接
  }
};


let animationInterval;

const startPacketCaptureAnimation = () => {
  let animationCounter = 0;
  animationInterval = setInterval(() => {
    const dots = Array(animationCounter % 5).fill('.').join('');
    buttonText.value = `正在抓包${dots}`;
    animationCounter++;
  }, 400); // 每隔400毫秒更新一次文字内容
};

const stopPacketCaptureAnimation = () => {
  clearInterval(animationInterval);
  buttonText.value = '开始抓包';
};

async function fetchData() {
  try {
    // 连接到 WebSocket 服务器
    socket = new WebSocket('ws://localhost:8000/ws');

    // 等待 WebSocket 连接建立成功
    await new Promise((resolve, reject) => {
      socket.onopen = resolve;
      socket.onerror = reject;
    });
    // 监听接收到的消息
    socket.onmessage = (event) => {
      // 更新 packets 数组
      const data = JSON.parse(event.data);
      var a=JSON.parse(data);
      // console.log(a);
      dataList.value.push(a);
    };
  } catch (error) {
    console.error('Failed to fetch data:', error);
  }
}
async function stopWebSocket() {
  if (socket && socket.readyState === WebSocket.OPEN) {
    // 如果连接是打开状态，则关闭连接
    socket.close();
  }
  buttonText.value = '开始抓包';
};


function toggleDetails(index) {
  // alert(index)
  expandedIndex.value = (expandedIndex.value === index) ? -1 : index
  expandedKey.value=""
}
function toggleDetailsKey(keyName1) {
  expandedKey.value = (expandedKey.value === keyName1) ? '' : keyName1
}
const protocolNames = {
    1: 'ICMP',
    6: 'TCP',
    17: 'UDP'
}

function getProtocolName(packet) {
    if (packet['info'].match("https")){
      return "HTTPS"
    }else if(packet['info'].match("http")){
      return "HTTP"
    }else{
      return protocolNames[packet['ip_layer']['protocol']] || 'Unknown'
    }
    
}
function getColor(protocol){
  // let backgroundColor=""
  let Class = ""
  if(protocol===1){
    Class="test1"
  }else if(protocol===6){
    Class="test2"
  }else if(protocol===17){
    Class="test3"
  }
  // return backgroundColor
  return Class
}
const downloadFile = async () => {
  try {
    // 发送 GET 请求到后端下载文件
    const response = await fetch('http://localhost:8000/download');
    
    // 将文件内容保存到blob对象中
    const blob = await response.blob();

    // 创建URL对象，用于浏览器下载
    const url = window.URL.createObjectURL(new Blob([blob]));

    // 创建a标签并设置下载链接
    const link = document.createElement('a');
    link.href = url;

    // 设置下载的文件名
    link.setAttribute('download', 'merged_packets.pcap');

    // 触发a标签点击事件，开始下载文件
    document.body.appendChild(link);
    link.click();

    // 移除a标签
    document.body.removeChild(link);

  } catch (error) {
    console.error('Failed to download file:', error);
  }
};

const handleFileUpload = (event) => {
  file.value = event.target.files[0];
};

const submitFile = async () => {
  try {
    const formData = new FormData();
    formData.append('file', file.value);
    const response = await axios.post('http://127.0.0.1:8000/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });

    if (response.data) {
      // 使用 map 方法将每个 Proxy 对象转换为原始的 JavaScript 对象
      dataList.value = response.data.map(proxy => JSON.parse(proxy));
      console.log('文件上传成功', dataList.value);
    }
    // 处理成功响应
  } catch (error) {
    console.error('文件上传失败', error);
    // 处理错误
  }
};

const handleRightClick = (event,packet) => {
  try {
    // alert('右键点击事件触发！');
    // 阻止默认的右键菜单行为
    event.preventDefault();
    // 从packet中获取相应的信息
    let srcMAC, dstMAC, srcIP, dstIP;
    srcMAC=packet["ethernet_layer"]["source_mac"];
    dstMAC=packet["ethernet_layer"]["destination_mac"];
    // alert(srcMAC)
    if (packet['arp_layer']){
      srcIP=packet['arp_layer']['protocol_source'];
      dstIP=packet['arp_layer']['protocol_dest'];
    }else{
      srcIP=packet['ip_layer']['source_ip'];
      dstIP=packet['ip_layer']['destination_ip'];
    }
    // 更新输入框的值
    localIP.value = srcIP;
    localMAC.value = srcMAC;
    targetIP.value = dstIP;
    targetMAC.value = dstMAC;
    attackSeconds.value=30
    // console.log(srcIP,srcMAC)
  } catch (error) {
    console.error('处理右键点击事件时出现错误：', error);
  }
};
const submitAttack = async () => {
    const formData = {
        local_ip: document.getElementById("localIP").value,
        local_mac: document.getElementById("localMAC").value,
        target_ip: document.getElementById("targetIP").value,
        target_mac: document.getElementById("targetMAC").value,
        attack_seconds: parseInt(document.getElementById("attackSeconds").value)
    };

    try {
        const response = await axios.post('http://localhost:8000/arpspoof', formData);
        // alert(response.data);
        // 处理成功响应
    } catch (error) {
      // alert('提交攻击时出错', error);
        // 处理错误
    }
};
</script>


<style scoped>
.mxa{
  margin-left: 50px;
}
.mxb{
  margin-bottom: 15px;
}
.input-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.input-row {
  display: flex;
  align-items: center;
}

.label {
  margin-right: 10px;
}

.rounded-input {
  border-radius: 5px;
}

.button-row {
  display: flex;
  justify-content: space-between;
}
.green-button {
  background-color: lightgreen; /* 设置绿色背景 */
  /* 其他样式 */
}
.button-container {
    display: flex;
    justify-content: space-between; /* 将项目水平排列并将空白空间分配给每个项目 */
}

.custom-button {
    padding: 15px 30px; /* 调整按钮的内边距，使其更大 */
    border-radius: 20px; /* 设置圆角为20px */
    width: 200px; /* 设置按钮宽度 */
    height: 200px; /* 设置按钮高度 */
    border: none; /* 移除边框 */
    cursor: pointer; /* 设置鼠标指针为手型 */
    transition: background-color 0.3s ease; /* 添加过渡效果 */
    margin: 30px;
}

.custom-button:hover {
    background-color: #aec990; /* 鼠标悬停时变成绿色 */
}

.large-button {
    font-size: 16px; /* 调整按钮文字大小 */
}



.test1{
  background-color: #93aecc
}
.test2{
  background-color: #bbf4fd;
  
}
.test3{
  background-color: #97c1c7
}
.messagea {
  width: 1000px;
  /* border: 2px solidrgba(99, 107, 112, 0.534)b;   */
  /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 8px; /* 圆角为8像素 */
  background-color: #f0f8ff; 
  /* 背景颜色为浅蓝色 */
  margin-bottom: 5px; /*添加底部边距*/
}
.detailsa {
  padding: 10px; /* 内边距为10像素 */
  border: 1px solid #ccc; /* 边框为1像素宽，颜色为灰色 */
  border-radius: 5px; /* 圆角为5像素 */
  background-color: #f9f9f9; /* 背景颜色为浅灰色 */
  margin-bottom: 5px; /* 添加底部边距 */
}
.card-body{
  margin-bottom: 5px; /* 设置段落间距 */
}
.test{
  width: 200px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius:6px; /* 圆角为8像素 */
  /* background-color: #f9f9f9;  */
  /* 背景颜色为浅蓝色 */
  padding: 8px;
  margin-right: 10px;
}
.noa{
  width: 60px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */
  /* background-color: #f9f9f9;  */
  /* 背景颜色为浅蓝色 */
  padding: 8px;
}
.infoa{
  width: 450px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */
  /* background-color: #f9f9f9;  */
  /* 背景颜色为浅蓝色 */
  padding: 8px;
}
.sticky-headera {
  position: sticky;
  top: 0;
  background-color: white; /* 表头背景色 */
  z-index: 1; /* 确保表头在最上层 */
}
th,
td {
  text-align: center; /* 表头和内容都居中对齐 */
  position: sticky;
  /* top: 0;  */
  /* 让表头固定在顶部 */
}
th::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 1px;
  height: 100%;
}
.left-align {
  text-align: left; /*左对齐*/
}
.newtest{
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 8px; /* 圆角为8像素 */
  margin-top: 3px;
  padding: 3px;
  margin-bottom: 3px;
  background-color:#b2e8ece3
}
.hover-effect:hover {
  background-color: #a5eccf; 
  /* 悬浮时的背景颜色 */
  /* background-color: #141414; */
}
.active{
  background-color: #a2dbac; 
}
.parent-container {
  width: 1050px; /* 父容器宽度 */
  height: 850px; /* 父容器高度 */
  border: 1px solid #ccc; /* 边框样式 */
  overflow-y: auto; /* 当内容超出父容器高度时显示垂直滚动条 */
}

.scrollable-content {
  padding: 10px; /* 内边距，使内容与边框保持距离 */
}

/* 可选样式：为滚动条添加自定义样式 */
.parent-container::-webkit-scrollbar {
  width: 8px;
}

.parent-container::-webkit-scrollbar-thumb {
  background-color: #888;
  border-radius: 4px;
}
</style>
