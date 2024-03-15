import { createRouter, createWebHistory } from 'vue-router';
import Home from './App.vue';
import Test from './app1.vue';

const rs = [
  {
    path: '/',
    name:"Home",
    component: Home
  },
  {
    path: '/test',
    name:"Test",
    component: Test
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes:rs
});

export default router;
