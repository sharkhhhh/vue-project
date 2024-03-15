<template>
  <div class="parent-container mt-3" >
    <div class="scrollable-content" >
    <table class="message">
      <thead class="sticky-header">
        <tr style="background-color: aquamarine;">
          <th class="no ">序号</th>
          <th class="test">source_ip</th>
          <th class="test">destination_ip</th>
          <th class="no">protocol</th>
          <th class="no">长度</th>
          <th class="info">info</th>
        </tr>
      </thead>
      <tbody v-for="(packet, index) in dataList" :key="index">
        <!-- {{ packet }} -->
        <tr  v-if="packet['arp_layer']"  class="hover-effect" @click="toggleDetails(index)" >
          <td class="no">{{index+1}}</td>
          <td class="test">{{ packet['arp_layer']['protocol_source'] }}</td>
          <td class="test">{{ packet['arp_layer']['protocol_dest'] }}</td>
          <td class="no">ARP</td>
          <td class="no">{{ packet['arp_layer']['hardware_length'] +20}}</td>
          <td class="info">{{ packet['info'] }} </td>
        </tr>
        <tr  v-else :class="getColor(packet['ip_layer']['protocol'])" class="hover-effect" @click="toggleDetails(index)" >
          <td class="no">{{index+1}}</td>
          <td class="test">{{ packet['ip_layer']['source_ip'] }}</td>
          <td class="test">{{ packet['ip_layer']['destination_ip'] }}</td>
          <td class="no">{{ getProtocolName(packet) }}</td>
          <td class="no">{{ packet['ip_layer']['total_length'] +20}}</td>
          <td class="info">{{ packet['info'] }} </td>
        </tr>
        <tr v-if="expandedIndex === index" >
          <td colspan="6" class="card-body details left-align">
            <div v-for="(fields, keyName) in packetKeys" :key="keyName" class="mb-3 newtest" style="background-color:beige">
              <div class="newtest hover-effect"  @click="toggleDetailsKey(keyName)" >
                <p v-show="keyName === 'ethernet_layer'">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src: {{ packet[keyName]['source_mac'] }}&nbsp;&nbsp; Dst: {{ packet[keyName]['destination_mac'] }}</p>
                <p v-show="keyName === 'ip_layer'">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src: {{ packet[keyName]['source_ip'] }}&nbsp;&nbsp; Dst: {{ packet[keyName]['destination_ip'] }}</p>
                <p v-show="keyName === 'tcp_layer'">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src Port: &nbsp;{{ packet[keyName]['source_port'] }}&nbsp;&nbsp; Dst Port: &nbsp;{{ packet[keyName]['destination_port'] }}&nbsp;&nbsp;&nbsp;&nbsp;Seq:&nbsp;{{ packet[keyName]['sequence_number'] }}&nbsp;&nbsp;&nbsp;&nbsp;Ack:&nbsp;{{ packet[keyName]['acknowledgment_number'] }}</p>
                <p v-show="keyName === 'arp_layer'">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src: {{ packet[keyName]['protocol_source'] }}&nbsp;&nbsp; Dst: {{ packet[keyName]['protocol_dest'] }}</p>
                <p v-show="keyName === 'icmp_layer'">&nbsp;&nbsp;{{ keyName }}</p>
                <p v-show="keyName === 'udp_layer'">&nbsp;&nbsp;{{ keyName }}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Src Port: &nbsp;{{ packet[keyName]['source_port'] }}&nbsp;&nbsp; Dst Port: &nbsp;{{ packet[keyName]['destination_port'] }}</p>
              </div>
              <div v-if="expandedKey === keyName" class="card-body" >
                <div v-for="field in fields" :key="field" class="active newtest hover-effect">
                  <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{{ field }}:&nbsp;&nbsp;{{packet[keyName][field]}}</p>
                </div>
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const dataList = ref([]) // 用于存储从后端接收的数据
const expandedIndex = ref(-1) // 用于跟踪哪个条状的详细数据被展开
const expandedKey = ref('')
const packetKeys = {
  'ethernet_layer': ['source_mac', 'destination_mac', 'ethernet_type'],
  'ip_layer': ['source_ip', 'destination_ip', 'ip_version', 'header_length', 'tos', 'total_length', 'ip_flags', 'identification', 'fragment_offset', 'ttl', 'protocol', 'header_checksum'],
  'tcp_layer': ['source_port', 'destination_port', 'sequence_number', 'acknowledgment_number', 'tcp_flags', 'window_size', 'checksum', 'urgent_pointer'],
  'arp_layer':["hardware_type","protocol_type","hardware_length","protocol_length","hardware_source","protocol_source","hardware_dest","protocol_dest"],
  'icmp_layer':[ "type","code","checksum","identifier","sequence"],
  'udp_layer':["source_port","destination_port","length","checksum"]
}
// 使用onMounted生命周期钩子来在组件挂载后获取数据

async function fetchData() {
  try {
    // 连接到 WebSocket 服务器
    const socket = new WebSocket('ws://localhost:8000/ws');

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
// 使用 onMounted 生命周期钩子来在组件挂载后获取数据

// onMounted(fetchData);
onMounted(async () => {
  fetchData()
})
// 点击条状标题时展开或收起详细数据


function toggleDetails(index) {
  // alert(index)
  expandedIndex.value = (expandedIndex.value === index) ? -1 : index

}
function toggleDetailsKey(keyName) {
  expandedKey.value = (expandedKey.value === keyName) ? '' : keyName
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
    // backgroundColor="background-color: #93aecc"
    Class="test1"
  }else if(protocol===6){
    // backgroundColor="background-color: #bbf4fd"
    Class="test2"
  }else if(protocol===17){
    // backgroundColor="background-color: #97c1c7"
    Class="test3"
  }
  // return backgroundColor
  return Class
}
</script>


<style scoped>
.test1{
  background-color: #93aecc
}
.test2{
  background-color: #bbf4fd
}
.test3{
  background-color: #97c1c7
}
.message {
  width: 1000px;
  border: 2px solidrgba(99, 107, 112, 0.534)b;  /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 8px; /* 圆角为8像素 */
  background-color: #f0f8ff; /* 背景颜色为浅蓝色 */
  margin-bottom: 5px; /*添加底部边距*/
}
.details {
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
  border-radius: 6px; /* 圆角为8像素 */
  /* background-color: #f9f9f9;  */
  /* 背景颜色为浅蓝色 */
  padding: 8px;
  margin-right: 10px;
}
.no{
  width: 50px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */
  /* background-color: #f9f9f9;  */
  /* 背景颜色为浅蓝色 */
  padding: 8px;
}
.info{
  width: 450px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */
  /* background-color: #f9f9f9;  */
  /* 背景颜色为浅蓝色 */
  padding: 8px;
}
.sticky-header {
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
