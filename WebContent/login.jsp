<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | EduTrack Pro - Student Attendance Management</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    
   <link rel="stylesheet" href="css/login.css">
</head>
<body>
    <div class="login-wrapper">
        <!-- Left Side - Welcome Section -->
        <div class="login-left">
            <div class="login-left-content">
                <div class="brand-logo">
                    <i class="fas fa-graduation-cap"></i>
                    EduTrack Pro
                </div>
                
                <h1 class="welcome-title">Authorized Access Portal</h1>
                
                <p class="welcome-subtitle">
                    This is a secure portal for registered institutional members only. Sign in with your authorized credentials to access your role-specific dashboard and attendance management tools.
                </p>
                
                <ul class="features-list">
                    <li>
                        <div class="feature-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div>
                           <strong>Secure Authentication:</strong> Protected access for verified members only
                        </div>
                    </li>
                    <li>
                        <div class="feature-icon">
                            <i class="fas fa-user-lock"></i>
                        </div>
                        <div>
                            <strong>Role-Based Access:</strong> Students, Teachers & Administrators
                        </div>
                    </li>
                    <li>
                        <div class="feature-icon">
                            <i class="fas fa-chart-line"></i>
                        </div>
                        <div>
                            <strong>Real-time Analytics:</strong> Instant insights and attendance tracking
                        </div>
                    </li>
                </ul>
                
              
                <div class="testimonial">
                    <p class="testimonial-text">
                        <i class="fas fa-lock me-2"></i>
                        <strong>Access Restricted:</strong> Only authorized institutional members with valid credentials can access this system. Contact your administrator for account registration.
                    </p>
                </div>
            </div>
        </div>
        
        <!-- Right Side - Login Form -->
        <div class="login-right">
            <div class="login-container">
                <div class="login-header">
                    <h2 class="login-title">Sign In to Your Account</h2>
                    <p class="login-subtitle">Enter your credentials to access the dashboard</p>
                </div>
                
                <!-- FIXED: Alert Messages - Check both parameters AND attributes -->
                <% 
                    // Check for error in request parameter (from URL) OR request attribute (from forward)
                    String error = request.getParameter("error");
                    if (error == null || error.isEmpty()) {
                        error = (String) request.getAttribute("error");
                    }
                    
                    // Check for success message
                    String success = request.getParameter("success");
                    if (success == null || success.isEmpty()) {
                        success = (String) request.getAttribute("success");
                    }
                    
                    String message = request.getParameter("message");
                    if (message == null || message.isEmpty()) {
                        message = (String) request.getAttribute("message");
                    }
                    
                    // Display error message
                    if (error != null && !error.isEmpty()) {
                %>
                    <div class="alert-message alert-error">
                        <i class="fas fa-exclamation-circle"></i>
                        <div><strong>Login Failed:</strong> <%= error %></div>
                    </div>
                <% } %>
                
                <% 
                    // Display success/message
                    if (success != null && !success.isEmpty()) { 
                %>
                    <div class="alert-message alert-success">
                        <i class="fas fa-check-circle"></i>
                        <div><%= success %></div>
                    </div>
                <% } else if (message != null && !message.isEmpty()) { %>
                    <div class="alert-message alert-success">
                        <i class="fas fa-info-circle"></i>
                        <div><%= message %></div>
                    </div>
                <% } %>
                
                <!-- Role Selection -->
                <div class="role-selection">
                    <p class="form-label mb-3">Select your role:</p>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <div class="role-option active" data-role="student" id="studentRole">
                                <i class="fas fa-user-graduate role-icon"></i>
                                <h6>Student</h6>
                                <p class="small text-muted mb-0">View attendance</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="role-option" data-role="teacher" id="teacherRole">
                                <i class="fas fa-chalkboard-teacher role-icon"></i>
                                <h6>Teacher</h6>
                                <p class="small text-muted mb-0">Mark attendance</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="role-option" data-role="admin" id="adminRole">
                                <i class="fas fa-user-shield role-icon"></i>
                                <h6>Administrator</h6>
                                <p class="small text-muted mb-0">Manage system</p>
                            </div>
                        </div>
                    </div>
                    <input type="hidden" name="role" id="selectedRole" value="student">
                </div>
                
                <!-- Login Form -->
                <form id="loginForm" action="login" method="post">
                    <!-- Username Field -->
                    <div class="form-group">
                        <label for="username" class="form-label">
                            <i class="fas fa-user"></i> Username or Email
                        </label>
                        <input type="text" class="form-control" id="username" name="username" 
                               placeholder="Enter your username or email" 
                               value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                               required>
                    </div>
                    
                    <!-- Password Field -->
                    <div class="form-group">
                        <label for="password" class="form-label">
                            <i class="fas fa-lock"></i> Password
                        </label>
                        <div class="input-group">
                            <input type="password" class="form-control" id="password" name="password" 
                                   placeholder="Enter your password" required>
                            <button type="button" class="password-toggle" id="togglePassword" title="Show password">
                                <i class="far fa-eye"></i>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Form Options -->
                    <div class="form-options">
                       
                        <a href="#forgotPassword" class="forgot-password" data-bs-toggle="modal" data-bs-target="#forgotPasswordModal">
                            <i class="fas fa-key me-1"></i> Forgot Password?
                        </a>
                    </div>
                    
                    <input type="hidden" name="role" id="formRole" value="student">
                    
                    <!-- Login Button -->
                    <button type="submit" class="btn btn-login" id="loginButton">
                        <i class="fas fa-sign-in-alt"></i> Sign In
                    </button>
                </form>
                
                <!-- Back to Home -->
                <div class="back-home">
                    <a href="index.jsp">
                        <i class="fas fa-arrow-left me-2"></i>
                        Back to Homepage
                    </a>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Forgot Password Modal -->
    <div class="modal fade" id="forgotPasswordModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Reset Password</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Please contact your system administrator to reset your password.</p>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        For security reasons, password reset must be initiated by the administrator.
                    </div>
                   
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
   
      <script src="js/login.js"></script>
</body>
</html>