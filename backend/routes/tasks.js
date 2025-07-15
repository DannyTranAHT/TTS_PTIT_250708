const express = require('express');
const { auth } = require('../middlewares/auth');
const {
  createTask,
  getAllTasks,
  getTaskById,
  assignMemberToTask,
  unassignMemberFromTask
} = require('../controllers/taskController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.post('/', createTask);
router.get('/project/:project_id', getAllTasks);
router.get('/:id', getTaskById);
router.post('/:id/assign', assignMemberToTask);
router.post('/:id/unassign', unassignMemberFromTask);

module.exports = router;
