const fs = require('fs');
const path = require('path');
const { swaggerSpec } = require('../swagger');

// Export swagger specification to JSON file
const exportSwaggerJson = () => {
  console.log('📤 Exporting Swagger specification to JSON...\n');
  
  try {
    // Create docs directory if it doesn't exist
    const docsDir = path.join(__dirname, '..', 'docs');
    if (!fs.existsSync(docsDir)) {
      fs.mkdirSync(docsDir);
      console.log('✅ Created docs directory');
    }

    // Export specification to JSON
    const jsonPath = path.join(docsDir, 'swagger.json');
    fs.writeFileSync(jsonPath, JSON.stringify(swaggerSpec, null, 2));
    console.log(`✅ Swagger specification exported to: ${jsonPath}`);

    // Export specification to YAML (if needed)
    const yaml = require('js-yaml');
    const yamlPath = path.join(docsDir, 'swagger.yaml');
    
    try {
      const yamlContent = yaml.dump(swaggerSpec, {
        indent: 2,
        lineWidth: 120,
        noRefs: false
      });
      fs.writeFileSync(yamlPath, yamlContent);
      console.log(`✅ Swagger specification exported to: ${yamlPath}`);
    } catch (yamlError) {
      console.log('⚠️  YAML export skipped (js-yaml not installed)');
    }

    // Generate API documentation summary
    generateApiSummary();
    
    console.log('\n🎉 Export completed successfully!');
    
  } catch (error) {
    console.error('❌ Export failed:', error.message);
    process.exit(1);
  }
};

// Generate API documentation summary
const generateApiSummary = () => {
  console.log('\n📋 Generating API summary...');
  
  const summaryPath = path.join(__dirname, '..', 'docs', 'api-summary.md');
  
  let summary = `# ${swaggerSpec.info.title} - API Summary\n\n`;
  summary += `**Version:** ${swaggerSpec.info.version}\n`;
  summary += `**Description:** ${swaggerSpec.info.description}\n\n`;
  
  // Add server information
  summary += `## Servers\n\n`;
  swaggerSpec.servers.forEach(server => {
    summary += `- **${server.description}:** ${server.url}\n`;
  });
  summary += '\n';
  
  // Add authentication info
  if (swaggerSpec.components?.securitySchemes) {
    summary += `## Authentication\n\n`;
    Object.entries(swaggerSpec.components.securitySchemes).forEach(([name, scheme]) => {
      summary += `- **${name}:** ${scheme.type} - ${scheme.description || ''}\n`;
    });
    summary += '\n';
  }
  
  // Add paths summary
  if (swaggerSpec.paths) {
    summary += `## API Endpoints\n\n`;
    
    // Group by tags
    const pathsByTag = {};
    Object.entries(swaggerSpec.paths).forEach(([path, methods]) => {
      Object.entries(methods).forEach(([method, details]) => {
        if (details.tags && details.tags.length > 0) {
          const tag = details.tags[0];
          if (!pathsByTag[tag]) {
            pathsByTag[tag] = [];
          }
          pathsByTag[tag].push({
            method: method.toUpperCase(),
            path,
            summary: details.summary || '',
            description: details.description || ''
          });
        }
      });
    });
    
    // Generate summary for each tag
    Object.entries(pathsByTag).forEach(([tag, endpoints]) => {
      summary += `### ${tag}\n\n`;
      endpoints.forEach(endpoint => {
        summary += `- **${endpoint.method}** \`${endpoint.path}\` - ${endpoint.summary}\n`;
      });
      summary += '\n';
    });
  }
  
  // Add schemas summary
  if (swaggerSpec.components?.schemas) {
    summary += `## Data Models\n\n`;
    Object.keys(swaggerSpec.components.schemas).forEach(schemaName => {
      summary += `- **${schemaName}**\n`;
    });
    summary += '\n';
  }
  
  summary += `---\n\n`;
  summary += `*Generated on: ${new Date().toISOString()}*\n`;
  summary += `*Documentation available at: /api-docs*\n`;
  
  fs.writeFileSync(summaryPath, summary);
  console.log(`✅ API summary generated: ${summaryPath}`);
};

// Generate Postman collection
const exportPostmanCollection = () => {
  console.log('📤 Generating Postman collection...');
  
  try {
    const collection = {
      info: {
        name: swaggerSpec.info.title,
        description: swaggerSpec.info.description,
        version: swaggerSpec.info.version,
        schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
      },
      auth: {
        type: "bearer",
        bearer: [
          {
            key: "token",
            value: "{{bearerToken}}",
            type: "string"
          }
        ]
      },
      variable: [
        {
          key: "baseUrl",
          value: swaggerSpec.servers[0]?.url || "http://localhost:5000",
          type: "string"
        },
        {
          key: "bearerToken",
          value: "your-jwt-token-here",
          type: "string"
        }
      ],
      item: []
    };
    
    // Convert Swagger paths to Postman items
    if (swaggerSpec.paths) {
      const folders = {};
      
      Object.entries(swaggerSpec.paths).forEach(([path, methods]) => {
        Object.entries(methods).forEach(([method, details]) => {
          const tag = details.tags?.[0] || 'Other';
          
          if (!folders[tag]) {
            folders[tag] = {
              name: tag,
              item: []
            };
          }
          
          const item = {
            name: details.summary || `${method.toUpperCase()} ${path}`,
            request: {
              method: method.toUpperCase(),
              header: [],
              url: {
                raw: `{{baseUrl}}${path}`,
                host: ["{{baseUrl}}"],
                path: path.split('/').filter(p => p)
              }
            }
          };
          
          // Add auth if required
          if (details.security) {
            item.request.auth = {
              type: "bearer",
              bearer: [
                {
                  key: "token",
                  value: "{{bearerToken}}",
                  type: "string"
                }
              ]
            };
          }
          
          folders[tag].item.push(item);
        });
      });
      
      collection.item = Object.values(folders);
    }
    
    const collectionPath = path.join(__dirname, '..', 'docs', 'postman-collection.json');
    fs.writeFileSync(collectionPath, JSON.stringify(collection, null, 2));
    console.log(`✅ Postman collection generated: ${collectionPath}`);
    
  } catch (error) {
    console.log('⚠️  Postman collection generation failed:', error.message);
  }
};

// Main export function
const exportSwagger = () => {
  console.log('🚀 Starting Swagger export...\n');
  
  exportSwaggerJson();
  exportPostmanCollection();
  
  console.log('\n📋 Export Summary:');
  console.log('- swagger.json - OpenAPI specification in JSON format');
  console.log('- swagger.yaml - OpenAPI specification in YAML format (if available)');
  console.log('- api-summary.md - Human-readable API documentation summary');
  console.log('- postman-collection.json - Ready-to-import Postman collection');
  console.log('\n💡 You can now import the Postman collection or use the JSON/YAML files with other API tools.');
};

// Run export if this file is executed directly
if (require.main === module) {
  exportSwagger();
}

module.exports = { exportSwagger, exportSwaggerJson, exportPostmanCollection };