// Socket Health Monitoring Middleware
const fs = require('fs').promises;
const path = require('path');

class SocketHealthMonitor {
  constructor() {
    this.metrics = {
      totalConnections: 0,
      activeConnections: 0,
      errors: [],
      performance: {
        avgResponseTime: 0,
        slowRequests: []
      },
      lastHealthCheck: new Date()
    };
    
    this.errorLog = [];
    this.maxErrorLog = 100; // Keep last 100 errors
    this.healthCheckInterval = null;
  }

  // Initialize monitoring
  init(io) {
    this.io = io;
    this.startHealthCheck();
    this.setupGlobalErrorHandling();
    console.log('✅ Socket Health Monitor initialized');
  }

  // Track connection events
  trackConnection(socket) {
    this.metrics.totalConnections++;
    this.metrics.activeConnections++;
    
    console.log(`📊 Connection tracked. Active: ${this.metrics.activeConnections}`);
  }

  trackDisconnection(socket, reason) {
    this.metrics.activeConnections = Math.max(0, this.metrics.activeConnections - 1);
    
    console.log(`📊 Disconnection tracked. Active: ${this.metrics.activeConnections}, Reason: ${reason}`);
  }

  // Track errors with context
  trackError(error, context = {}) {
    const errorEntry = {
      timestamp: new Date(),
      message: error.message,
      stack: error.stack,
      context,
      id: `error_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    };

    this.errorLog.unshift(errorEntry);
    
    // Keep only last N errors
    if (this.errorLog.length > this.maxErrorLog) {
      this.errorLog = this.errorLog.slice(0, this.maxErrorLog);
    }

    // Log critical errors immediately
    if (this.isCriticalError(error)) {
      this.logCriticalError(errorEntry);
    }

    console.error(`🚨 Socket Error tracked: ${error.message}`);
  }

  // Check if error is critical
  isCriticalError(error) {
    const criticalPatterns = [
      /authentication/i,
      /database/i,
      /cannot emit/i,
      /socket.*disconnect/i,
      /memory/i
    ];

    return criticalPatterns.some(pattern => 
      pattern.test(error.message) || pattern.test(error.stack || '')
    );
  }

  // Log critical errors to file
  async logCriticalError(errorEntry) {
    try {
      const logDir = path.join(__dirname, '../logs');
      const logFile = path.join(logDir, 'socket_critical_errors.log');
      
      // Ensure log directory exists
      try {
        await fs.access(logDir);
      } catch {
        await fs.mkdir(logDir, { recursive: true });
      }

      const logLine = `${errorEntry.timestamp.toISOString()} - ${errorEntry.id}\n` +
                     `Message: ${errorEntry.message}\n` +
                     `Context: ${JSON.stringify(errorEntry.context)}\n` +
                     `Stack: ${errorEntry.stack}\n` +
                     '---\n';

      await fs.appendFile(logFile, logLine);
    } catch (logError) {
      console.error('❌ Failed to log critical error:', logError);
    }
  }

  // Periodic health checks
  startHealthCheck() {
    this.healthCheckInterval = setInterval(() => {
      this.performHealthCheck();
    }, 60000); // Every minute

    console.log('⏰ Socket health check started (60s interval)');
  }

  async performHealthCheck() {
    try {
      const health = {
        timestamp: new Date(),
        io_status: this.io ? 'connected' : 'disconnected',
        active_connections: this.metrics.activeConnections,
        recent_errors: this.errorLog.slice(0, 5),
        engine_status: null,
        room_count: 0
      };

      if (this.io && this.io.engine) {
        health.engine_status = {
          clients_count: this.io.engine.clientsCount,
          ping_timeout: this.io.engine.pingTimeout,
          ping_interval: this.io.engine.pingInterval
        };

        // Count active rooms
        if (this.io.sockets && this.io.sockets.adapter) {
          health.room_count = this.io.sockets.adapter.rooms.size;
        }
      }

      this.metrics.lastHealthCheck = health.timestamp;

      // Alert if issues detected
      if (this.detectIssues(health)) {
        await this.alertOnIssues(health);
      }

      console.log(`💓 Health check completed - Active: ${health.active_connections}, Rooms: ${health.room_count}`);
      
    } catch (healthError) {
      console.error('❌ Health check failed:', healthError);
      this.trackError(healthError, { source: 'health_check' });
    }
  }

  // Detect potential issues
  detectIssues(health) {
    const issues = [];

    // Too many errors recently
    const recentErrors = this.errorLog.filter(
      error => Date.now() - error.timestamp.getTime() < 300000 // Last 5 minutes
    );
    if (recentErrors.length > 10) {
      issues.push('high_error_rate');
    }

    // No active connections for too long
    if (health.active_connections === 0 && this.metrics.totalConnections > 0) {
      issues.push('no_active_connections');
    }

    // Engine issues
    if (health.engine_status && health.engine_status.clients_count !== health.active_connections) {
      issues.push('connection_count_mismatch');
    }

    return issues.length > 0;
  }

  // Alert on issues (could send to monitoring service)
  async alertOnIssues(health) {
    console.warn('🚨 Socket health issues detected:', health);
    
    // Here you could integrate with monitoring services like:
    // - Sentry
    // - DataDog
    // - Custom alerting system
    // - Email notifications
    
    // For now, just log to file
    try {
      const alertFile = path.join(__dirname, '../logs/socket_alerts.log');
      const alertData = `${new Date().toISOString()} - Health Alert\n${JSON.stringify(health, null, 2)}\n---\n`;
      await fs.appendFile(alertFile, alertData);
    } catch (logError) {
      console.error('❌ Failed to log health alert:', logError);
    }
  }

  // Setup global error handling
  setupGlobalErrorHandling() {
    // Catch unhandled socket errors
    process.on('uncaughtException', (error) => {
      if (error.message && error.message.includes('socket')) {
        this.trackError(error, { source: 'uncaught_exception' });
      }
    });

    process.on('unhandledRejection', (reason, promise) => {
      if (reason && reason.toString().includes('socket')) {
        this.trackError(new Error(reason), { source: 'unhandled_rejection' });
      }
    });
  }

  // Get current metrics
  getMetrics() {
    return {
      ...this.metrics,
      recent_errors: this.errorLog.slice(0, 10),
      error_count: this.errorLog.length
    };
  }

  // Cleanup
  cleanup() {
    if (this.healthCheckInterval) {
      clearInterval(this.healthCheckInterval);
      this.healthCheckInterval = null;
    }
    console.log('🧹 Socket Health Monitor cleaned up');
  }
}

// Singleton instance
const socketHealthMonitor = new SocketHealthMonitor();

module.exports = {
  SocketHealthMonitor,
  socketHealthMonitor
};