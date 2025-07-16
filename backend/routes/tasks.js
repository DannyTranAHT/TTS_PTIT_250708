const express = require('express');
const { auth } = require('../middlewares/auth');
const {
  createTask,
  getAllTasks,
  getTaskById,
  assignMemberToTask,
  unassignMemberFromTask,
  updateTask,
  requestCompleteTask,
  confirmCompleteTask
} = require('../controllers/taskController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.post('/', createTask);
router.get('/project/:project_id', getAllTasks);
router.get('/:id', getTaskById);
router.put('/:id', updateTask);
router.post('/:id/assign', assignMemberToTask);
router.post('/:id/unassign', unassignMemberFromTask);
router.post('/:id/request-complete', requestCompleteTask);
router.post('/:id/confirm-complete', confirmCompleteTask);

module.exports = router;
