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
    
    <style>
        /* [Keep all your existing CSS exactly as is - I'm only showing the changed parts below] */
        :root {
            --primary: #4361ee;
            --primary-dark: #3a56d4;
            --secondary: #7209b7;
            --success: #4cc9f0;
            --danger: #f72585;
            --warning: #f8961e;
            --dark: #212529;
            --light: #f8f9fa;
            --gray: #6c757d;
            --light-gray: #e9ecef;
            --border-radius: 12px;
            --box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            --transition: all 0.3s ease;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
            min-height: 100vh;
            color: var(--dark);
            display: flex;
            align-items: center;
        }
        
        .login-wrapper {
            width: 100%;
            min-height: 100vh;
            display: flex;
        }
        
        .login-left {
            flex: 1;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 60px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        
        .login-left::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -30%;
            width: 600px;
            height: 600px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
        }
        
        .login-left::after {
            content: '';
            position: absolute;
            bottom: -30%;
            left: -20%;
            width: 400px;
            height: 400px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
        }
        
        .login-left-content {
            position: relative;
            z-index: 1;
        }
        
        .brand-logo {
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            font-size: 2.5rem;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .welcome-title {
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            font-size: 2.8rem;
            margin-bottom: 20px;
            line-height: 1.2;
        }
        
        .welcome-subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
            margin-bottom: 40px;
            line-height: 1.6;
        }
        
        .features-list {
            list-style: none;
            padding: 0;
            margin-bottom: 50px;
        }
        
        .features-list li {
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 1.05rem;
        }
        
        .feature-icon {
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        
        .testimonial {
            background: rgba(255, 255, 255, 0.1);
            padding: 25px;
            border-radius: var(--border-radius);
            margin-top: 40px;
            border-left: 4px solid white;
        }
        
        .testimonial-text {
            font-style: italic;
            margin-bottom: 15px;
            line-height: 1.6;
        }
        
        .login-right {
            flex: 1;
            padding: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .login-container {
            width: 100%;
            max-width: 480px;
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .login-title {
            font-family: 'Poppins', sans-serif;
            font-weight: 600;
            font-size: 2.2rem;
            color: var(--dark);
            margin-bottom: 10px;
        }
        
        .login-subtitle {
            color: var(--gray);
            font-size: 1rem;
        }
        
        .role-selection {
            margin-bottom: 30px;
        }
        
        .role-option {
            padding: 20px;
            border: 2px solid var(--light-gray);
            border-radius: var(--border-radius);
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
            background: white;
        }
        
        .role-option:hover {
            border-color: var(--primary);
            background: rgba(67, 97, 238, 0.02);
        }
        
        .role-option.active {
            border-color: var(--primary);
            background: rgba(67, 97, 238, 0.08);
            position: relative;
        }
        
        .role-option.active::before {
            content: '✓';
            position: absolute;
            top: -10px;
            right: -10px;
            width: 25px;
            height: 25px;
            background: var(--primary);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
        }
        
        .role-icon {
            font-size: 2.2rem;
            margin-bottom: 10px;
            display: block;
        }
        
        .role-option[data-role="admin"] .role-icon {
            color: var(--danger);
            font-size: 3.5rem;
            font-weight: 600;
        }
        
        .role-option[data-role="teacher"] .role-icon {
            color: var(--warning);
            font-size: 2.2rem;
        }
        
        .role-option[data-role="student"] .role-icon {
            color: var(--success);
            font-size: 2.2rem;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-label {
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .input-group {
            position: relative;
        }
        
        .form-control {
            padding: 15px 50px 15px 15px;
            border: 2px solid var(--light-gray);
            border-radius: 10px;
            font-size: 1rem;
            transition: var(--transition);
            height: 52px;
            width: 100%;
        }
        
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
        }
        
        .password-toggle {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--gray);
            cursor: pointer;
            font-size: 1.2rem;
            padding: 5px;
            z-index: 10;
            transition: var(--transition);
        }
        
        .password-toggle:hover {
            color: var(--primary);
        }
        
        .btn-login {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 15px;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 1.1rem;
            width: 100%;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(67, 97, 238, 0.3);
            color: white;
        }
        
        /* FIXED: Alert message styles with shake animation */
        .alert-message {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideInDown 0.5s ease, shake 0.5s ease 0.5s;
            font-size: 0.95rem;
        }
        
        .alert-error {
            background: rgba(247, 37, 133, 0.1);
            border-left: 4px solid var(--danger);
            color: #d90429;
            border: 1px solid rgba(247, 37, 133, 0.3);
        }
        
        .alert-error i {
            color: var(--danger);
            font-size: 1.3rem;
        }
        
        .alert-success {
            background: rgba(76, 201, 240, 0.1);
            border-left: 4px solid var(--success);
            color: #118ab2;
            border: 1px solid rgba(76, 201, 240, 0.3);
        }
        
        .alert-success i {
            color: var(--success);
            font-size: 1.3rem;
        }
        
        @keyframes slideInDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
            20%, 40%, 60%, 80% { transform: translateX(5px); }
        }
        
        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 20px 0 30px;
        }
        
        .form-check {
            margin-bottom: 0;
        }
        
        .form-check-input {
            width: 18px;
            height: 18px;
            margin-right: 8px;
            cursor: pointer;
        }
        
        .form-check-label {
            cursor: pointer;
            font-size: 0.95rem;
            color: var(--gray);
        }
        
        .forgot-password {
            font-size: 0.95rem;
            color: var(--primary);
            text-decoration: none;
            transition: var(--transition);
        }
        
        .forgot-password:hover {
            text-decoration: underline;
        }
        
        .back-home {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid var(--light-gray);
        }
        
        .back-home a {
            color: var(--gray);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }
        
        .back-home a:hover {
            color: var(--primary);
        }
        
        .create-account {
            text-align: center;
            margin-top: 20px;
            padding: 15px;
            background: rgba(67, 97, 238, 0.05);
            border-radius: 10px;
            border: 1px dashed var(--primary);
        }
        
        .create-account a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
        }
        
        .create-account a:hover {
            text-decoration: underline;
        }
        
        @media (max-width: 992px) {
            .login-wrapper {
                flex-direction: column;
            }
            
            .login-left, .login-right {
                padding: 40px 20px;
            }
            
            .welcome-title {
                font-size: 2.2rem;
            }
        }
        
        @media (max-width: 576px) {
            .brand-logo {
                font-size: 2rem;
            }
            
            .welcome-title {
                font-size: 1.8rem;
            }
            
            .login-title {
                font-size: 1.8rem;
            }
            
            .role-option {
                padding: 15px;
            }
            
            .form-options {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }
    </style>
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
                
                <h1 class="welcome-title">Welcome Back</h1>
                
                <p class="welcome-subtitle">
                    Sign in to access your personalized dashboard and manage student attendance 
                    with our powerful analytics and reporting tools.
                </p>
                
                <ul class="features-list">
                    <li>
                        <div class="feature-icon">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <div>
                            <strong>Secure Authentication:</strong> Bank-level encryption and secure login
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
                        "EduTrack Pro has simplified our attendance management. The interface is intuitive and reports are generated automatically."
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
    
    <script>
        // Password visibility toggle
        document.getElementById('togglePassword').addEventListener('click', function() {
            const passwordInput = document.getElementById('password');
            const icon = this.querySelector('i');
            
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
                this.title = "Hide password";
            } else {
                passwordInput.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
                this.title = "Show password";
            }
        });
        
        // Role selection
        const roleOptions = document.querySelectorAll('.role-option');
        const formRoleInput = document.getElementById('formRole');
        const selectedRoleInput = document.getElementById('selectedRole');
        
        // Pre-select role if coming back from failed login
        <% 
            String preselectedRole = (String) request.getAttribute("role");
            if (preselectedRole != null && !preselectedRole.isEmpty()) {
        %>
            const preselectedRole = '<%= preselectedRole %>';
            roleOptions.forEach(opt => {
                if (opt.getAttribute('data-role') === preselectedRole) {
                    roleOptions.forEach(o => o.classList.remove('active'));
                    opt.classList.add('active');
                    formRoleInput.value = preselectedRole;
                    selectedRoleInput.value = preselectedRole;
                }
            });
        <% } %>
        
        roleOptions.forEach(option => {
            option.addEventListener('click', function() {
                roleOptions.forEach(opt => opt.classList.remove('active'));
                this.classList.add('active');
                
                const role = this.getAttribute('data-role');
                formRoleInput.value = role;
                selectedRoleInput.value = role;
                
                const usernameInput = document.getElementById('username');
                if (role === 'student') {
                    usernameInput.placeholder = "Enter your student ID or email";
                } else if (role === 'teacher') {
                    usernameInput.placeholder = "Enter your teacher ID or email";
                } else if (role === 'admin') {
                    usernameInput.placeholder = "Enter your administrator username";
                }
            });
        });
        
        // Auto-focus username on page load
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('username').focus();
        });
    </script>
</body>
</html>