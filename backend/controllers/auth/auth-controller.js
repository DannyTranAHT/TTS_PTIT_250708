const User = require('../../models/user/user-model');
const { generateToken } = require('../../services/jwt/jwt-service');
const validator = require('validator');

exports.register = async (req, res) => {
  try {
    const { username, email, full_name, password, role } = req.body;

    // 1. Validate cơ bản
    if (!username || !email || !password || !full_name) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (!validator.isEmail(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    const allowedRoles = ['Project Manager', 'Employee'];
    if (role && !allowedRoles.includes(role)) {
      return res.status(400).json({ error: 'Invalid role value' });
    }

    // 2. Kiểm tra tồn tại
    const existingUser = await User.findOne({ $or: [{ username }, { email: email.toLowerCase().trim() }] });
    if (existingUser) {
      return res.status(409).json({ error: 'Username or email already exists' });
    }

    // 3. Tạo và lưu user
    const newUser = new User({
      username: username.trim(),
      email: email.toLowerCase().trim(),
      password,
      full_name: full_name.trim(),
      role: role || 'Employee',
      major: major || 'NoInfor',
      avatar: avatar || null,
    });

    await newUser.save();

    const token = generateToken(newUser);

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email,
        role: newUser.role,
        full_name: newUser.full_name,
        major: newUser.major,
        avatar: newUser.avatar
      }
    });
  } catch (err) {
    console.error('[REGISTER ERROR]', err);
    res.status(500).json({ error: 'Internal server error' });
  }
};


exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ error: 'Username does not exist' });
    }
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Incorrect password' });
    }

    const token = generateToken(user);
    res.json({
      token,
      user: {
        id: user._id,
        username: user.username,
        full_name: user.full_name,
        role: user.role,
        email: user.email,
        avatar: user.avatar
      }
    });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
};
exports.logout = async (req, res) => {
  try {
    res.clearCookie('token');

    return res.status(200).json({ message: 'Logout successful' });
  } catch (err) {
    console.error('[LOGOUT ERROR]', err);
    res.status(500).json({ error: 'Server error' });
  }
};