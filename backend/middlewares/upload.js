const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure upload directories exist
const ensureDirectoriesExist = () => {
  const directories = [
    './uploads',
    './uploads/avatars',
    './uploads/tasks',
    './uploads/projects',
    './uploads/comments'
  ];

  directories.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });
};

// Initialize directories
ensureDirectoriesExist();

// Storage configuration
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    let uploadPath = './uploads/';
    
    // Determine upload path based on field name or route
    if (file.fieldname === 'avatar') {
      uploadPath = './uploads/avatars/';
    } else if (req.originalUrl.includes('/tasks/')) {
      uploadPath = './uploads/tasks/';
    } else if (req.originalUrl.includes('/projects/')) {
      uploadPath = './uploads/projects/';
    } else if (req.originalUrl.includes('/comments/')) {
      uploadPath = './uploads/comments/';
    }
    
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, extension);
    
    // Sanitize filename
    const sanitizedBaseName = baseName.replace(/[^a-zA-Z0-9]/g, '_');
    const filename = `${sanitizedBaseName}-${uniqueSuffix}${extension}`;
    
    cb(null, filename);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  console.log('🔍 File validation:');
  console.log('🔍 Field name:', file.fieldname);
  console.log('🔍 Original name:', file.originalname);
  console.log('🔍 MIME type:', file.mimetype);
  console.log('🔍 Route:', req.originalUrl);
  
  // Define allowed file types based on field name
  let allowedMimeTypes;
  let allowedExtensions;
  
  if (file.fieldname === 'avatar') {
    // Only images for avatars - more comprehensive MIME types
    allowedMimeTypes = [
      'image/jpeg',
      'image/jpg', 
      'image/png',
      'image/gif',
      'image/webp',
      'image/bmp',
      'image/tiff'
    ];
    allowedExtensions = /\.(jpeg|jpg|png|gif|webp|bmp|tiff)$/i;
  } else {
    // Images and documents for other uploads
    allowedMimeTypes = [
      'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp',
      'application/pdf', 
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
      'text/csv',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ];
    allowedExtensions = /\.(jpeg|jpg|png|gif|webp|pdf|doc|docx|txt|csv|xlsx|xls)$/i;
  }
  
  // Check MIME type
  const mimeTypeValid = allowedMimeTypes.includes(file.mimetype);
  
  // Check file extension
  const extensionValid = allowedExtensions.test(file.originalname);
  
  console.log('🔍 MIME type valid:', mimeTypeValid);
  console.log('🔍 Extension valid:', extensionValid);
  
  // Accept if either MIME type OR extension is valid (some systems report incorrect MIME types)
  if (mimeTypeValid || extensionValid) {
    console.log('✅ File validation passed');
    return cb(null, true);
  } else {
    const errorMessage = file.fieldname === 'avatar' 
      ? `Invalid avatar file. Received MIME type: ${file.mimetype}, filename: ${file.originalname}. Only image files (JPEG, PNG, GIF, WebP) are allowed.`
      : `Invalid file type. Received MIME type: ${file.mimetype}. Please upload images or documents only.`;
    console.log('❌ File validation failed:', errorMessage);
    cb(new Error(errorMessage));
  }
};

// Multer configuration
const upload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024 // 5MB
  },
  fileFilter
});

module.exports = upload;