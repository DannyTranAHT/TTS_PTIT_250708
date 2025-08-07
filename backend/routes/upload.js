const express = require('express');
const path = require('path');
const { auth } = require('../middlewares/auth');
const upload = require('../middlewares/upload'); // Direct import
const User = require('../models/User');

const router = express.Router();

// Helper function to validate file type (consistent with file filter logic)
const isValidImageFile = (file) => {
  // Check MIME type
  const allowedMimeTypes = [
    'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 
    'image/webp', 'image/bmp', 'image/tiff'
  ];
  const mimeTypeValid = allowedMimeTypes.includes(file.mimetype);
  
  // Check file extension
  const allowedExtensions = /\.(jpeg|jpg|png|gif|webp|bmp|tiff)$/i;
  const extensionValid = allowedExtensions.test(file.originalname);
  
  // Accept if either MIME type OR extension is valid (consistent with file filter)
  return mimeTypeValid || extensionValid;
};

// Upload avatar
router.post('/avatar', auth, (req, res, next) => {
  
  upload.single('avatar')(req, res, (err) => {
    if (err) {
      
      // Handle different types of multer errors
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({
          success: false,
          message: 'File too large. Maximum size is 5MB.'
        });
      }
      
      if (err.code === 'LIMIT_UNEXPECTED_FILE') {
        return res.status(400).json({
          success: false,
          message: 'Unexpected field in file upload. Expected field name: avatar'
        });
      }
      
      // Custom validation errors
      if (err.message.includes('Invalid avatar file') || err.message.includes('Only image files')) {
        return res.status(400).json({
          success: false,
          message: err.message
        });
      }
      
      // Generic multer error
      return res.status(400).json({
        success: false,
        message: `Upload error: ${err.message}`
      });
    }
    
    // Continue to main handler
    next();
  });
}, async (req, res) => {
  try {
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded. Please select an image file.'
      });
    }

    // Use consistent validation logic (same as file filter)
    if (!isValidImageFile(req.file)) {
      return res.status(400).json({
        success: false,
        message: `Invalid file type. File: ${req.file.originalname}, MIME type: ${req.file.mimetype}. Only image files (JPEG, PNG, GIF, WebP) are allowed.`
      });
    }

    // Generate file path (relative to project root for serving)
    const avatarPath = `uploads/avatars/${req.file.filename}`;
    
    // Update user avatar in database
    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      { avatar: avatarPath },
      { new: true, runValidators: true }
    ).select('-password');

    if (!updatedUser) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Avatar uploaded successfully',
      file_path: avatarPath,
      avatar_url: avatarPath,
      user: updatedUser,
      file_info: {
        original_name: req.file.originalname,
        size: req.file.size,
        mime_type: req.file.mimetype,
        validation_note: req.file.mimetype === 'application/octet-stream' ? 'File validated by extension due to generic MIME type' : 'File validated by MIME type'
      }
    });

  } catch (error) {
    console.error('❌ Avatar upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload avatar',
      error: error.message
    });
  }
});

// Upload file for tasks/projects
router.post('/file', auth, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    const filePath = `uploads/${req.file.filename}`;
    
    res.json({
      success: true,
      message: 'File uploaded successfully',
      file_path: filePath,
      file_name: req.file.originalname,
      file_size: req.file.size,
      file_type: req.file.mimetype
    });

  } catch (error) {
    console.error('File upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload file',
      error: error.message
    });
  }
});

module.exports = router;