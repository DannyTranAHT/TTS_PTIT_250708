// Mock email service - implement with real email provider like SendGrid, Mailgun, etc.
const sendEmail = async ({ to, subject, text, html }) => {
    try {
      // In development, just log the email
      if (process.env.NODE_ENV === 'development') {
        console.log('\n--- EMAIL SENT ---');
        console.log(`To: ${to}`);
        console.log(`Subject: ${subject}`);
        console.log(`Text: ${text}`);
        if (html) console.log(`HTML: ${html}`);
        console.log('--- END EMAIL ---\n');
        return { success: true, messageId: 'dev-' + Date.now() };
      }
      
      // TODO: Implement real email sending
      // Example with nodemailer:
      /*
      const nodemailer = require('nodemailer');
      
      const transporter = nodemailer.createTransporter({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS
        }
      });
      
      const mailOptions = {
        from: process.env.EMAIL_FROM,
        to,
        subject,
        text,
        html
      };
      
      const result = await transporter.sendMail(mailOptions);
      return result;
      */
      
      return { success: true, messageId: 'mock-' + Date.now() };
    } catch (error) {
      console.error('Error sending email:', error);
      throw error;
    }
  };
  
  const sendTaskReminderEmail = async (user, task, project) => {
    const subject = `Reminder: Task "${task.name}" is due soon`;
    const text = `
      Hi ${user.full_name},
      
      This is a reminder that your task "${task.name}" in project "${project.name}" is due on ${task.due_date.toLocaleDateString()}.
      
      Please log in to the system to update the task status.
      
      Best regards,
      Project Management Team
    `;
    
    const html = `
      <h2>Task Reminder</h2>
      <p>Hi ${user.full_name},</p>
      <p>This is a reminder that your task "<strong>${task.name}</strong>" in project "<strong>${project.name}</strong>" is due on <strong>${task.due_date.toLocaleDateString()}</strong>.</p>
      <p>Please log in to the system to update the task status.</p>
      <p>Best regards,<br>Project Management Team</p>
    `;
    
    return await sendEmail({
      to: user.email,
      subject,
      text,
      html
    });
  };
  
  const sendProjectInvitationEmail = async (user, project, invitedBy) => {
    const subject = `You've been added to project: ${project.name}`;
    const text = `
      Hi ${user.full_name},
      
      You have been added to the project "${project.name}" by ${invitedBy.full_name}.
      
      Please log in to the system to view the project details.
      
      Best regards,
      Project Management Team
    `;
    
    const html = `
      <h2>Project Invitation</h2>
      <p>Hi ${user.full_name},</p>
      <p>You have been added to the project "<strong>${project.name}</strong>" by <strong>${invitedBy.full_name}</strong>.</p>
      <p>Please log in to the system to view the project details.</p>
      <p>Best regards,<br>Project Management Team</p>
    `;
    
    return await sendEmail({
      to: user.email,
      subject,
      text,
      html
    });
  };
  
module.exports = {
    sendEmail,
    sendTaskReminderEmail,
    sendProjectInvitationEmail
};