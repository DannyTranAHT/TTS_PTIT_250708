import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/users';

export const getAllUsers = () =>
  axios
    .get(`${API_BASE}/`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getUserById = (id) =>
  axios
    .get(`${API_BASE}/${id}`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getUserByEmail = (email) =>
  axios
    .get(`${API_BASE}/search/by-email`, {
      params: { email },
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const updateUser = (id, userData) =>
  axios
    .put(`${API_BASE}/${id}`, userData, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const deactivateUser = (id) =>
  axios
    .put(`${API_BASE}/${id}/deactivate`, null, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const activateUser = (id) =>
  axios
    .put(`${API_BASE}/${id}/activate`, null, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const changePassword = (id, passwordData) =>
  axios
    .put(`${API_BASE}/${id}/change-password`, passwordData, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);
export const getUserProjects = (id) =>
  axios
    .get(`${API_BASE}/${id}/projects`, {
      headers: {
        Authorization: localStorage.getItem('token'),
      },
    })
    .then((res) => res.data);