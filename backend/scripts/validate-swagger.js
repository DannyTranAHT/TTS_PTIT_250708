const fs = require('fs');
const path = require('path');
const { swaggerSpec } = require('../swagger');

// Validate swagger specification
const validateSwaggerSpec = () => {
  console.log('🔍 Validating Swagger specification...\n');
  
  try {
    // Check if swagger spec is properly generated
    if (!swaggerSpec) {
      throw new Error('Swagger specification is not defined');
    }

    // Check required properties
    const requiredProps = ['openapi', 'info', 'servers', 'components'];
    const missingProps = requiredProps.filter(prop => !swaggerSpec[prop]);
    
    if (missingProps.length > 0) {
      throw new Error(`Missing required properties: ${missingProps.join(', ')}`);
    }

    // Check info section
    if (!swaggerSpec.info.title || !swaggerSpec.info.version) {
      throw new Error('API info must include title and version');
    }

    // Check servers
    if (!Array.isArray(swaggerSpec.servers) || swaggerSpec.servers.length === 0) {
      throw new Error('At least one server must be defined');
    }

    // Check components schemas
    const components = swaggerSpec.components;
    if (!components.schemas || Object.keys(components.schemas).length === 0) {
      console.log('⚠️  Warning: No schemas defined in components');
    }

    // Check paths
    if (!swaggerSpec.paths || Object.keys(swaggerSpec.paths).length === 0) {
      console.log('⚠️  Warning: No API paths documented');
    } else {
      console.log(`✅ Found ${Object.keys(swaggerSpec.paths).length} documented API paths`);
    }

    console.log('✅ Swagger specification is valid!\n');
    
    // Print summary
    printSpecSummary();
    
    return true;
  } catch (error) {
    console.error('❌ Swagger validation failed:', error.message);
    return false;
  }
};

// Print specification summary
const printSpecSummary = () => {
  console.log('📊 Swagger Specification Summary:');
  console.log(`   Title: ${swaggerSpec.info.title}`);
  console.log(`   Version: ${swaggerSpec.info.version}`);
  console.log(`   Description: ${swaggerSpec.info.description || 'No description'}`);
  console.log(`   Servers: ${swaggerSpec.servers?.length || 0}`);
  console.log(`   Schemas: ${Object.keys(swaggerSpec.components?.schemas || {}).length}`);
  console.log(`   Paths: ${Object.keys(swaggerSpec.paths || {}).length}`);
  
  if (swaggerSpec.components?.securitySchemes) {
    console.log(`   Security Schemes: ${Object.keys(swaggerSpec.components.securitySchemes).length}`);
  }
  
  console.log('');
};

// Check required files exist
const checkRequiredFiles = () => {
  console.log('📁 Checking required files...\n');
  
  const requiredFiles = [
    'swagger.js',
    'swagger/paths/auth.js',
    'swagger/paths/projects.js',
    'swagger/paths/tasks.js',
    'swagger/paths/users.js',
    'swagger/paths/comments-notifications.js'
  ];

  const missingFiles = [];
  
  requiredFiles.forEach(file => {
    const filePath = path.join(__dirname, '..', file);
    if (fs.existsSync(filePath)) {
      console.log(`✅ ${file}`);
    } else {
      console.log(`❌ ${file} - Missing!`);
      missingFiles.push(file);
    }
  });

  if (missingFiles.length > 0) {
    console.log(`\n⚠️  Missing files: ${missingFiles.join(', ')}`);
    return false;
  }
  
  console.log('\n✅ All required files found!\n');
  return true;
};

// Main validation function
const validateSwagger = () => {
  console.log('🚀 Starting Swagger validation...\n');
  
  const filesExist = checkRequiredFiles();
  if (!filesExist) {
    console.log('❌ File validation failed. Please ensure all required files exist.');
    process.exit(1);
  }
  
  const specValid = validateSwaggerSpec();
  if (!specValid) {
    console.log('❌ Specification validation failed.');
    process.exit(1);
  }
  
  console.log('🎉 All validations passed! Your Swagger documentation is ready.');
  console.log('💡 Start your server and visit /api-docs to view the documentation.\n');
};

// Run validation if this file is executed directly
if (require.main === module) {
  validateSwagger();
}

module.exports = { validateSwagger, validateSwaggerSpec, checkRequiredFiles };