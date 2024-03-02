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
      <tbody v-for="(item, index) in dataList" :key="index">
        <tr @click="toggleDetails(index)">
          <td class="no">{{index+1}}</td>
          <td class="test">{{ item['源IP地址'] }}</td>
          <td class="test">{{ item['目标IP地址'] }}</td>
          <td class="no">TCP</td>
          <td class="no">{{ item['Payload内容'] +20}}</td>
          <td class="info">{{ item['info'].substring(0, 40)+"...."}}</td>
        </tr>
        <tr v-if="expandedIndex === index">
          <td colspan="6" class="card-body details">
            <!-- 这里展示其他详细数据 -->
            <p>源端口号: {{ dataList[expandedIndex]['源端口号'] }}</p>
            <p>目标端口号: {{ dataList[expandedIndex]['目标端口号'] }}</p>
            <p>Payload内容: {{ dataList[expandedIndex]['Payload内容'] }}</p>
            <p>源MAC地址: {{ dataList[expandedIndex]['源MAC地址'] }}</p>
            <p>目标MAC地址: {{ dataList[expandedIndex]['目标MAC地址'] }}</p>
            <p>type: {{ dataList[expandedIndex]['type'] }}</p>
            <p>Version: {{ dataList[expandedIndex]['Version'] }}</p>
            <p>seq: {{ dataList[expandedIndex]['seq'] }}</p>
            <p>info: {{ dataList[expandedIndex]['info'] }}</p>
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
.gap{
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
th::after {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 1px;
  height: 100%;
  
}
</style>
