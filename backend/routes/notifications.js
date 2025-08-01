const express = require('express');
const { auth } = require('../middlewares/auth');
const { validate, notificationSchemas } = require('../middlewares/validation');
const {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getUnreadCount
} = require('../controllers/notificationController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.get('/', getNotifications);
router.get('/unread-count', getUnreadCount);
router.put('/:id/read', validate(notificationSchemas.updateRead),markAsRead);
router.put('/mark-all-read', markAllAsRead);
router.delete('/:id', deleteNotification);

module.exports = router;