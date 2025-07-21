const express = require('express');
const { validate, authSchemas } = require('../middlewares/validation');
const { auth } = require('../middlewares/auth');
const {
  register,
  login,
  getProfile,
  updateProfile,
  refreshTokenHandler
} = require('../controllers/authController');

const router = express.Router();

router.post('/register', validate(authSchemas.register), register);
router.post('/login', validate(authSchemas.login), login);
router.get('/profile', auth, getProfile);
router.put('/profile', auth, updateProfile);
router.post('/refresh-token', refreshTokenHandler);

module.exports = router;
