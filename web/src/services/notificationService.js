import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/notifications';

export const getNotifications = () => 
  axios
    .get(`${API_BASE}/`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const markAsRead = (id, is_read) =>
  axios
    .put(`${API_BASE}/${id}/read`, is_read , {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const markAllAsRead = () =>
  axios
    .put(`${API_BASE}/mark-all-read`, {}, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const deleteNotification = (id) =>
  axios
    .delete(`${API_BASE}/${id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getUnreadCount = () =>
  axios
    .get(`${API_BASE}/unread-count`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);