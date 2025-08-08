import React, { createContext, useEffect, useState } from 'react';
import { refreshToken } from '../services/authService';
import {jwtDecode} from 'jwt-decode';

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const interval = setInterval(async () => {
      const token = localStorage.getItem('token');
      const refresh = localStorage.getItem('refreshToken');

      if (token) {
        try {
          const { exp } = jwtDecode(token);
          const now = Math.floor(Date.now() / 1000);

          if (exp - now <= 5) {
            if (!refresh) {
              console.log('Không có refresh token → logout');
              logoutUser();
              return;
            }

            try {
              const response = await refreshToken(refresh);
              localStorage.setItem('token', response.token);
              if (response.refreshToken) {
                localStorage.setItem('refreshToken', response.refreshToken);
              }
              console.log('🔁 Token refreshed thành công!');
            } catch (err) {
              console.log('❌ Refresh token không hợp lệ → logout');
              logoutUser();
            }
          }
        } catch (err) {
          console.log('Decode lỗi → logout');
          logoutUser();
        }
      }
    }, 900000); // 15 phút

    return () => clearInterval(interval);
  }, []);

  const logoutUser = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('refreshToken');
    localStorage.removeItem('user');
    alert('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    window.location.href = '/login';
  };

  return (
    <AuthContext.Provider value={{ user, setUser, logoutUser }}>
      {children}
    </AuthContext.Provider>
  );
};