import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/projects';

export const getAllProjects = ({page, limit}) =>
  axios
    .get(`${API_BASE}/?page=${page}&limit=${limit}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const createProject = (data) =>
  axios
    .post(`${API_BASE}/`, data, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getProjectById = (id) =>
  axios
    .get(`${API_BASE}/${id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const updateProject = (id, data) =>
  axios
    .put(`${API_BASE}/${id}`, data, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const deleteProject = (id) =>
  axios
    .delete(`${API_BASE}/${id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const addMemberToProject = (id, userId) =>
  axios
    .post(`${API_BASE}/${id}/members`, { user_id: userId }, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const removeMemberFromProject = (id, userId) =>
  axios
    .delete(`${API_BASE}/${id}/members/${userId}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
