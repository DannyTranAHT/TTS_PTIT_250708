const express = require('express');
const { auth, authorize } = require('../middlewares/auth');

const router = express.Router();

// Socket health check endpoint
router.get('/socket-health', auth, authorize('Admin'), (req, res) => {
  try {
    const io = req.app.get('io');
    const socketHandlers = req.app.get('socketHandlers');
    
    const healthData = {
      status: 'healthy',
      timestamp: new Date(),
      socket_info: {
        connected_clients: io?.engine?.clientsCount || 0,
        engine_upgrade_count: io?.engine?.upgradeCount || 0,
      },
      server_info: {
        uptime: process.uptime(),
        memory_usage: process.memoryUsage(),
        node_version: process.version,
      }
    };

    // Add analytics if available
    if (socketHandlers?.getAnalytics) {
      healthData.analytics = socketHandlers.getAnalytics();
    }

    if (socketHandlers?.getActiveConnections) {
      healthData.active_connections = socketHandlers.getActiveConnections();
    }

    res.json(healthData);
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date()
    });
  }
});

// Socket metrics endpoint
router.get('/socket-metrics', auth, authorize('Admin'), (req, res) => {
  try {
    const socketHandlers = req.app.get('socketHandlers');
    
    if (!socketHandlers?.getAnalytics) {
      return res.status(404).json({ message: 'Analytics not available' });
    }

    const metrics = socketHandlers.getAnalytics();
    res.json(metrics);
  } catch (error) {
    res.status(500).json({
      error: error.message,
      timestamp: new Date()
    });
  }
});

module.exports = router;