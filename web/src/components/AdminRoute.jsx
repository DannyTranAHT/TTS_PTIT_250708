import React from 'react';
import { Navigate } from 'react-router-dom';

const AdminRoute = ({ children }) => {
  const user = JSON.parse(localStorage.getItem('user'));

  // Kiểm tra nếu user tồn tại và có role là 'admin'
  if (user && user.role === 'Admin') {
    return children;
  }

  // Nếu không phải admin, chuyển hướng về trang login
  return <Navigate to="/admin/login" />;
};

export default AdminRoute;