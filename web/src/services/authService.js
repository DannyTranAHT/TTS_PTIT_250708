import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/auth';

export const registerUser = (data) =>
  axios.post(`${API_BASE}/register`, data).then((res) => res.data);

export const loginUser = (data) =>
  axios.post(`${API_BASE}/login`, data).then((res) => res.data);

export const refreshToken = () =>
  axios
    .post(`${API_BASE}/refresh-token`, {
      refreshToken: localStorage.getItem('refreshToken'),
    })
    .then((res) => res.data);
