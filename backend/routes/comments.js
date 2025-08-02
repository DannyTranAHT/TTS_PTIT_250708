const express = require('express');
const { auth } = require('../middlewares/auth');
const { validate, commentSchemas } = require('../middlewares/validation');
const {
  getComments,
  createComment,
  updateComment,
  deleteComment
} = require('../controllers/commentController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.get('/', getComments);
router.post('/',validate(commentSchemas.create), createComment);
router.put('/:id',validate(commentSchemas.update), updateComment);
router.delete('/:id', deleteComment);

module.exports = router;