const express = require('express');
const { auth, authorize } = require('../middlewares/auth');
const { validate, projectSchemas } = require('../middlewares/validation');
const {
  getAllProjects,
  getRecentProjects,
  getProjectById,
  createProject,
  updateProject,
  deleteProject,
  addMember,
  getMembers,
  removeMember
} = require('../controllers/projectController');

const router = express.Router();

// All routes require authentication
router.use(auth);

router.get('/', getAllProjects);
router.get('/recent', getRecentProjects);
router.get('/:id', getProjectById);
router.post('/', validate(projectSchemas.create), createProject);
router.put('/:id',validate(projectSchemas.update), updateProject);
router.delete('/:id', authorize('Admin', 'Project Manager'), deleteProject);
router.post('/:id/members', addMember);
router.delete('/:id/members/:user_id', removeMember);
router.get('/:id/members', getMembers);

module.exports = router;