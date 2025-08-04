import { io } from 'socket.io-client';

const socket = io('http://localhost:5000', {
  auth: {
    token: localStorage.getItem('token') // Gửi token để xác thực
  },
  autoConnect: false // Không tự động kết nối
});

export default socket;