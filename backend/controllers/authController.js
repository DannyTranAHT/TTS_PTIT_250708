const jwt = require('jsonwebtoken');
const User = require('../models/User');

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '1h' // Thời gian hết hạn của token
  });
};

// Thêm hàm sinh refresh token
const generateRefreshToken = (id) => {
  const issuedAt = Math.floor(Date.now() / 1000);
  return jwt.sign({ id, iat: issuedAt }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: '3h' // Thời gian hết hạn của refresh token
  });
};


const register = async (req, res) => {
  try {
    const { username, email, password, full_name, role, major } = req.body;

    // Check if user exists
    const existingUser = await User.findOne({ 
      $or: [{ email }, { username }] 
    });
    
    if (existingUser) {
      return res.status(400).json({ 
        message: 'User already exists with this email or username' 
      });
    }

    // Create user
    const user = await User.create({
      username,
      email,
      password,
      full_name,
      role: role || 'Employee',
      major
    });

    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.status(201).json({
      message: 'User registered successfully',
      token,
      refreshToken,
      user
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, username, password } = req.body;
    if(username && password) {
      // Login by username
      const user = await User.findOne({ username }).select('+password');
      if (!user || !await user.comparePassword(password)) {
        return res.status(401).json({ message: 'Invalid username or password' });
      }
     
      const token = generateToken(user._id);
      const refreshToken = generateRefreshToken(user._id);
      return res.json({
        message: 'Login successful',
        token,
        refreshToken,
        user: user.toJSON()
      });
    }
    // Find user
    const user = await User.findOne({ email }).select('+password');
    
    if (!user || !await user.comparePassword(password)) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    if (!user.is_active) {
      return res.status(401).json({ message: 'Account is deactivated' });
    }
    const token = generateToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    res.json({
      message: 'Login successful',
      token,
      refreshToken,
      user: user.toJSON()
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// API làm mới access token từ refresh token
const refreshTokenHandler = (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(401).json({ message: 'Refresh token required' });
  }
  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    // Kiểm tra thời gian hợp lệ trong 2 ngày
    const issuedAt = decoded.iat * 1000; // Chuyển từ giây sang milliseconds
    const now = Date.now();
    const twoDaysInMs = 2 * 24 * 60 * 60 * 1000; // 2 ngày (milliseconds)

    if (now - issuedAt > twoDaysInMs) {
      return res.status(401).json({ message: 'Refresh token expired after 2 days' });
    }

    // Tạo Access Token mới
    const newToken = generateToken(decoded.id);
    res.json({ token: newToken });
  } catch (error) {
    res.status(401).json({ message: 'Invalid or expired refresh token' });
  }
};

const getProfile = async (req, res) => {
  try {
    res.json({ user: req.user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { full_name, major } = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { full_name, major },
      { new: true, runValidators: true }
    );

    res.json({
      message: 'Profile updated successfully',
      user
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  refreshTokenHandler
};
