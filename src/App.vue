<template>
  <div class="container mt-3">
    <table class="message">
      <thead class="sticky-header">
        <tr >
          <th class="no ">No</th>
          <th class="test">源IP地址:</th>
          <th class="test">目标IP地址:</th>
          <th class="no">Protocol:</th>
          <th class="no">Length:</th>
          <th class="info">info:</th>
        </tr>
      </thead>
      <tbody v-for="(packet, index) in dataList" :key="index">
        <tr @click="toggleDetails(index)">
          <td class="no">{{index+1}}</td>
          <td class="test">{{ packet['IP层']['源IP地址'] }}</td>
          <td class="test">{{ packet['IP层']['目标IP地址'] }}</td>
          <td class="no">TCP</td>
          <td class="no">{{ packet['IP层']['总长度'] +20}}</td>
          <td class="info">Ether / IP / TCP 192.168.1.5:43416 > 20.....</td>
        </tr>
        <tr v-if="expandedIndex === index" >
          <td colspan="6" class="card-body details left-align">
            <div v-for="(fields, keyName) in packetKeys" :key="keyName" class="card mb-3 newtest" >
              <div class="card-header newtest" @click="toggleDetailsKey(keyName)" >
                {{ keyName }}
              </div>
              <div v-if="expandedKey === keyName" class="card-body" style="background-color: #59d6a6">
                <div v-for="field in fields" :key="field" class="newtest">
                  <p>&nbsp;&nbsp;&nbsp;&nbsp;{{ field }}:{{packet[keyName][field]}}</p>
                </div>
              </div>
            </div>
          </td>

        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const dataList = ref([]) // 用于存储从后端接收的数据
const expandedIndex = ref(-1) // 用于跟踪哪个条状的详细数据被展开
const packetKeys = {
  '以太网层': ['源MAC地址', '目标MAC地址', '以太网类型'],
  'TCP层': ['源端口号', '目标端口号', '序列号', '确认号', 'TCP标志位', '窗口大小', '校验和', '紧急指针', '选项'],
  'IP层': ['源IP地址', '目标IP地址', 'IP版本', 'IP头部长度', '服务类型(TOS)', '总长度', '标识', '片偏移', '生存时间(TTL)', '协议', '头部校验和', '选项']
}
const expandedKey = ref('')
const fields = ref([])
// 使用onMounted生命周期钩子来在组件挂载后获取数据
onMounted(async () => {
  fetchData()
})

// 发送HTTP GET请求获取数据的函数
async function fetchData() {
  try {
    const response = await axios.get('http://localhost:8000')
    dataList.value = response.data
  } catch (error) {
    console.error('Failed to fetch data:', error)
  }
}

// 点击条状标题时展开或收起详细数据
function toggleDetails(index) {
  // alert("click")
  expandedIndex.value = (expandedIndex.value === index) ? -1 : index
}
function toggleDetailsKey(keyName) {
  // alert(keyName)
  expandedKey.value = (expandedKey.value === keyName) ? '' : keyName
  // alert(expandedKey)
}
</script>


<style scoped>
.message {
  width: 1000px;
  border: 2px solid #3498db; /* 边框为2像素宽，颜色为浅蓝色 */
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
  background-color: #f9f9f9; /* 背景颜色为浅蓝色 */
  padding: 8px;
  margin-right: 10px;
}

.no{
  width: 50px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */
  background-color: #f9f9f9; /* 背景颜色为浅蓝色 */
  padding: 8px;
  margin-right: 10px;
}
.info{
  width: 450px;
  height: 100%;
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */
  background-color: #f9f9f9; /* 背景颜色为浅蓝色 */
  padding: 8px;
  margin-right: 10px;
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
  top: 0; /* 让表头固定在顶部 */
}
.left-align {
  text-align: left; /*左对齐*/
}
th::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 1px;
  height: 100%;
  
}
.newtest{
  border: 1px solid #636364; /* 边框为2像素宽，颜色为浅蓝色 */
  border-radius: 6px; /* 圆角为8像素 */

  padding: 4px;
  margin-bottom: 5px;
}

.a{
  background-color: #59d6a6;
}
</style>
