import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/tasks';

export const getAllTasks = (project_id) =>
  axios
    .get(`${API_BASE}/project/${project_id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getTaskById = (id) =>
  axios
    .get(`${API_BASE}/${id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const createTask = (task) =>
  axios
    .post(`${API_BASE}/`, task, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const updateTask = (id, task) =>
  axios
    .put(`${API_BASE}/${id}`, task, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data); 
export const assignMemberToTask = (id, memberId) =>
  axios
    .post(`${API_BASE}/${id}/assign`, { memberId }, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);

export const unassignMemberFromTask = (id, memberId) =>
  axios
    .post(`${API_BASE}/${id}/unassign`, { memberId }, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const requestCompleteTask = (id) =>
  axios
    .post(`${API_BASE}/${id}/request-complete`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const confirmCompleteTask = (id, confirm) =>
  axios
    .post(`${API_BASE}/${id}/confirm-complete`, { confirm }, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getMyTasks = () =>
  axios
    .get(`${API_BASE}/my`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);