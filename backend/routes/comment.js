const express = require('express');
const { auth } = require('../middlewares/auth');
const {
  createComment,
  updateComment,
  deleteComment,
  getComments
} = require('../controllers/commentController');

const router = express.Router();

router.use(auth);
router.post('/', createComment);
router.put('/:id', updateComment);
router.delete('/:id', deleteComment);
router.get('/', getComments);

module.exports = router;