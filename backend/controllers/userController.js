const User = require('../models/User');
const Project = require('../models/Project');

const getAllUsers = async (req, res) => {
  try {
    const { page = 1, limit = 10, role, search, active_only = 'true' } = req.query;
    
    // Only admins and project managers can see all users
    if (req.user.role === 'Employee') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const query = {};

    // Filter by role
    if (role && role !== 'all') {
      query.role = role;
    }

    // Filter by active status
    if (active_only === 'true') {
      query.is_active = true;
    }

    // Search filter
    if (search) {
      query.$or = [
        { username: { $regex: search, $options: 'i' } },
        { full_name: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ created_at: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await User.countDocuments(query);

    res.json({
      users,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await User.findById(id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get user's project statistics
    const projectStats = await Project.aggregate([
      {
        $match: {
          $or: [
            { owner_id: user._id },
            { members: user._id }
          ],
          is_archived: false
        }
      },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);

    const stats = {
      total_projects: 0,
      owned_projects: 0,
      member_projects: 0
    };

    // Count owned vs member projects
    const ownedProjects = await Project.countDocuments({ 
      owner_id: user._id, 
      is_archived: false 
    });
    const memberProjects = await Project.countDocuments({ 
      members: user._id, 
      owner_id: { $ne: user._id },
      is_archived: false 
    });

    stats.owned_projects = ownedProjects;
    stats.member_projects = memberProjects;
    stats.total_projects = ownedProjects + memberProjects;

    res.json({
      user,
      stats
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getUserByEmail = async (req, res) => {
  try {
    const { email } = req.query;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const user = await User.findOne({ email }).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    // Users can only update their own profile, admins can update anyone
    if (req.user._id.toString() !== id && req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Remove sensitive fields that shouldn't be updated via this endpoint
    delete updates.password;
    delete updates._id;

    // Only admins can change roles
    if (updates.role && req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Only admins can change user roles' });
    }

    const user = await User.findByIdAndUpdate(
      id,
      updates,
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      message: 'User updated successfully',
      user
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const deactivateUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Only admins can deactivate users
    if (req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    // Cannot deactivate yourself
    if (req.user._id.toString() === id) {
      return res.status(400).json({ message: 'Cannot deactivate your own account' });
    }

    const user = await User.findByIdAndUpdate(
      id,
      { is_active: false },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      message: 'User deactivated successfully',
      user
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const activateUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Only admins can activate users
    if (req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const user = await User.findByIdAndUpdate(
      id,
      { is_active: true },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      message: 'User activated successfully',
      user
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const changePassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { current_password, new_password } = req.body;

    // Users can only change their own password
    if (req.user._id.toString() !== id) {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const user = await User.findById(id).select('+password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Verify current password
    const isCurrentPasswordValid = await user.comparePassword(current_password);
    if (!isCurrentPasswordValid) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }

    // Update password
    user.password = new_password;
    await user.save();

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getUserProjects = async (req, res) => {
  try {
    const { id } = req.params;

    // Users can only see their own projects unless they're admin
    if (req.user._id.toString() !== id && req.user.role !== 'Admin') {
      return res.status(403).json({ message: 'Permission denied' });
    }

    const projects = await Project.find({
      $or: [
        { owner_id: id },
        { members: id }
      ],
      is_archived: false
    })
    .populate('owner_id', 'username full_name')
    .sort({ created_at: -1 });

    res.json({ projects });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  getUserByEmail,
  updateUser,
  deactivateUser,
  activateUser,
  changePassword,
  getUserProjects
};
