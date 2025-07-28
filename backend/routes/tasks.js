const express = require('express');
const { auth } = require('../middlewares/auth');
const { validate, taskSchemas } = require('../middlewares/validation');
const {
  createTask,
  getAllTasks,
  getTaskById,
  assignMemberToTask,
  unassignMemberFromTask,
  updateTask,
  requestCompleteTask,
  confirmCompleteTask,
  getMyTasks
} = require('../controllers/taskController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.post('/',validate(taskSchemas.create), createTask);
router.get('/my', getMyTasks);
router.get('/project/:project_id', getAllTasks);
router.get('/:id', getTaskById);
router.put('/:id',validate(taskSchemas.update), updateTask);
router.post('/:id/assign', assignMemberToTask);
router.post('/:id/unassign', unassignMemberFromTask);
router.post('/:id/request-complete', requestCompleteTask);
router.post('/:id/confirm-complete', confirmCompleteTask);

module.exports = router;
