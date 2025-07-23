const fs = require('fs');
const path = require('path');

// Tạo cấu trúc thư mục cho Swagger
const createDirectories = () => {
  const directories = [
    'swagger',
    'swagger/paths',
    'uploads',
    'uploads/avatars',
    'uploads/tasks',
    'uploads/comments',
    'uploads/projects'
  ];

  directories.forEach(dir => {
    const dirPath = path.join(__dirname, dir);
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
      console.log(`✅ Created directory: ${dir}`);
    } else {
      console.log(`📁 Directory already exists: ${dir}`);
    }
  });
};

// Tạo file gitkeep để đảm bảo thư mục upload được track
const createGitkeepFiles = () => {
  const uploadDirs = [
    'uploads/avatars',
    'uploads/tasks', 
    'uploads/comments',
    'uploads/projects'
  ];

  uploadDirs.forEach(dir => {
    const gitkeepPath = path.join(__dirname, dir, '.gitkeep');
    if (!fs.existsSync(gitkeepPath)) {
      fs.writeFileSync(gitkeepPath, '# Keep this directory in git\n');
      console.log(`✅ Created .gitkeep in: ${dir}`);
    }
  });
};

// Tạo file index.js cho swagger/paths
const createSwaggerPathsIndex = () => {
  const indexPath = path.join(__dirname, 'swagger/paths', 'index.js');
  const indexContent = `// Import all API documentation files
require('./auth');
require('./projects');
require('./tasks');
require('./users');
require('./comments-notifications');

module.exports = {
  message: 'All API documentation paths loaded'
};`;

  if (!fs.existsSync(indexPath)) {
    fs.writeFileSync(indexPath, indexContent);
    console.log('✅ Created swagger/paths/index.js');
  }
};

// Main setup function
const setupSwagger = () => {
  console.log('🚀 Setting up Swagger documentation structure...\n');
  
  try {
    createDirectories();
    console.log('');
    
    createGitkeepFiles();
    console.log('');
    
    createSwaggerPathsIndex();
    console.log('');
    
    console.log('✨ Swagger setup completed successfully!');
    console.log('\n📋 Next steps:');
    console.log('1. Copy all swagger documentation files to their respective locations');
    console.log('2. Update your app.js with Swagger integration');
    console.log('3. Install dependencies: npm install swagger-jsdoc swagger-ui-express');
    console.log('4. Start your server and visit: http://localhost:5000/api-docs');
    console.log('5. Test your API endpoints using the interactive documentation\n');
    
  } catch (error) {
    console.error('❌ Error setting up Swagger:', error.message);
    process.exit(1);
  }
};

// Run setup if this file is executed directly
if (require.main === module) {
  setupSwagger();
}

module.exports = { setupSwagger };