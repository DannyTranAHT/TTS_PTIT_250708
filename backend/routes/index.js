const express = require('express');
const authRoutes = require('./auth/auth-routes');

function router(app) {
  app.use('/api/auth', authRoutes);

};

module.exports = router;
