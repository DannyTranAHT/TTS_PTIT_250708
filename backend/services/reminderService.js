const cron = require('node-cron');
const Task = require('../models/Task');
const User = require('../models/User');
const Project = require('../models/Project');
const { createNotification } = require('./notificationService');
const { sendTaskReminderEmail } = require('./emailService');

class ReminderService {
  constructor() {
    this.isRunning = false;
  }

  // Start the reminder scheduler
  start() {
    if (this.isRunning) {
      console.log('Reminder service is already running');
      return;
    }

    // Run every hour at minute 0
    this.cronJob = cron.schedule('0 * * * *', async () => {
      await this.checkDueTasks();
    }, {
      scheduled: false
    });

    this.cronJob.start();
    this.isRunning = true;
    console.log('Task reminder service started');
  }

  // Stop the reminder scheduler
  stop() {
    if (this.cronJob) {
      this.cronJob.stop();
      this.isRunning = false;
      console.log('Task reminder service stopped');
    }
  }

  // Check for tasks due in the next 24-48 hours
  async checkDueTasks() {
    try {
      console.log('Checking for due tasks...');
      
      const now = new Date();
      const next24Hours = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const next48Hours = new Date(now.getTime() + 48 * 60 * 60 * 1000);

      // Find tasks due in next 24-48 hours
      const dueTasks = await Task.find({
        due_date: {
          $gte: next24Hours,
          $lte: next48Hours
        },
        status: { $ne: 'Done' },
        is_archived: false,
        assigned_to_id: { $exists: true }
      })
      .populate('assigned_to_id', 'email full_name username')
      .populate('project_id', 'name');

      console.log(`Found ${dueTasks.length} tasks due soon`);

      // Send reminders for each task
      for (const task of dueTasks) {
        if (task.assigned_to_id && task.project_id) {
          await this.sendTaskReminder(task);
        }
      }

      // Also check for overdue tasks
      await this.checkOverdueTasks();

    } catch (error) {
      console.error('Error checking due tasks:', error);
    }
  }

  // Check for overdue tasks
  async checkOverdueTasks() {
    try {
      const now = new Date();
      
      const overdueTasks = await Task.find({
        due_date: { $lt: now },
        status: { $ne: 'Done' },
        is_archived: false,
        assigned_to_id: { $exists: true }
      })
      .populate('assigned_to_id', 'email full_name username')
      .populate('project_id', 'name');

      console.log(`Found ${overdueTasks.length} overdue tasks`);

      for (const task of overdueTasks) {
        if (task.assigned_to_id && task.project_id) {
          await this.sendOverdueNotification(task);
        }
      }
    } catch (error) {
      console.error('Error checking overdue tasks:', error);
    }
  }

  // Send task reminder
  async sendTaskReminder(task) {
    try {
      const user = task.assigned_to_id;
      const project = task.project_id;

      // Create in-app notification
      await createNotification({
        user_id: user._id,
        type: 'due_date_reminder',
        title: 'Task Due Soon',
        message: `Task "${task.name}" is due on ${task.due_date.toLocaleDateString()}`,
        related_entity: {
          entity_type: 'Task',
          entity_id: task._id
        }
      });

      // Send email reminder
      await sendTaskReminderEmail(user, task, project);

      console.log(`Reminder sent for task: ${task.name} to ${user.email}`);
    } catch (error) {
      console.error(`Error sending reminder for task ${task._id}:`, error);
    }
  }

  // Send overdue notification
  async sendOverdueNotification(task) {
    try {
      const user = task.assigned_to_id;

      // Create in-app notification
      await createNotification({
        user_id: user._id,
        type: 'due_date_reminder',
        title: 'Task Overdue',
        message: `Task "${task.name}" was due on ${task.due_date.toLocaleDateString()} and is now overdue`,
        related_entity: {
          entity_type: 'Task',
          entity_id: task._id
        }
      });

      console.log(`Overdue notification sent for task: ${task.name} to ${user.email}`);
    } catch (error) {
      console.error(`Error sending overdue notification for task ${task._id}:`, error);
    }
  }

  // Manual trigger for testing
  async triggerManualCheck() {
    console.log('Manual reminder check triggered');
    await this.checkDueTasks();
  }
}

// Create singleton instance
const reminderService = new ReminderService();

module.exports = reminderService;