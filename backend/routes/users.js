const express = require('express');
const { auth, authorize } = require('../middlewares/auth');
const {
  getAllUsers,
  getUserById,
  updateUser,
  deactivateUser,
  activateUser,
  changePassword,
  getUserProjects
} = require('../controllers/userController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.get('/', authorize('Admin', 'Project Manager'), getAllUsers);
router.get('/:id', getUserById);
router.put('/:id', updateUser);
router.put('/:id/deactivate', authorize('Admin'), deactivateUser);
router.put('/:id/activate', authorize('Admin'), activateUser);
router.put('/:id/change-password', changePassword);
router.get('/:id/projects', getUserProjects);

module.exports = router;