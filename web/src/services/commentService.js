import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/comments';

export const getComment = (taskId) =>
  axios
    .get(`${API_BASE}/?entity_type=Task&entity_id=${taskId}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const createComment = (comment) =>
  axios
    .post(`${API_BASE}/`, comment, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const updateComment = (id, comment) =>
  axios
    .put(`${API_BASE}/${id}`, comment, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const deleteComment = (id) =>
  axios
    .delete(`${API_BASE}/${id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
