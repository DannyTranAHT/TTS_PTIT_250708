const jwt = require('jsonwebtoken');
const User = require('../models/User');

const generateTokens = (userId) => {
  const accessToken = jwt.sign(
    { id: userId }, 
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
  
  // If you want refresh tokens, add them here
  const refreshToken = jwt.sign(
    { id: userId, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
  
  return { accessToken, refreshToken };
};

const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid token');
  }
};

const findUserByCredentials = async (email, password) => {
  const user = await User.findOne({ email }).select('+password');
  
  if (!user || !await user.comparePassword(password)) {
    throw new Error('Invalid email or password');
  }
  
  if (!user.is_active) {
    throw new Error('Account is deactivated');
  }
  
  return user;
};

const createUser = async (userData) => {
  // Check if user already exists
  const existingUser = await User.findOne({
    $or: [
      { email: userData.email },
      { username: userData.username }
    ]
  });
  
  if (existingUser) {
    throw new Error('User already exists with this email or username');
  }
  
  const user = await User.create(userData);
  return user;
};

module.exports = {
  generateTokens,
  verifyToken,
  findUserByCredentials,
  createUser
};