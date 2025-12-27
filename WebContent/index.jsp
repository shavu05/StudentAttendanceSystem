
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduTrack Pro | Student Attendance Management System</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <!-- Animate CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    
   <link rel="stylesheet" href="css/index.css">

</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-graduation-cap brand-logo"></i>
                EduTrack Pro
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <i class="fas fa-bars"></i>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="index.jsp">Home</a>
                    </li>
                     <li class="nav-item">
                        <a class="nav-link" href="#about">About</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#features">Features</a>
                    </li>
                   
                    <li class="nav-item">
                        <a class="nav-link" href="#contact">Contact</a>
                    </li>
                    <li class="nav-item ms-2">
                        <a href="login.jsp" class="btn btn-outline-primary">Login</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    
    <!-- Hero Section -->
    <section class="hero-section">
        <div class="floating-element floating-1"></div>
        <div class="floating-element floating-2"></div>
        
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6 hero-content">
                    <h1 class="hero-title animate__animated animate__fadeInUp">
                        Student Attendance Management System
                    </h1>
                    <p class="hero-subtitle animate__animated animate__fadeInUp animate__delay-1s">
                       A comprehensive digital platform for educational institutions to track, analyze, and manage student attendance with precision, security, and ease.
                    </p>
                    <div class="mt-4 animate__animated animate__fadeInUp animate__delay-2s">
                        <a href="login.jsp" class="btn btn-primary btn-lg me-3">
                            <i class="fas fa-rocket me-2"></i>Access System
                        </a>
                    </div>
                </div>

            </div>
        </div>
    </section>
    
    <!-- About Section -->   
     <section id="about" class="about-section">        
     <div class="container">            
     <h2 class="section-title">About EduTrack Pro</h2>            
     <div class="row align-items-center">                
     <div class="col-lg-6">                    
     <p class="about-text">                       
      <strong>EduTrack Pro</strong> is a smart and reliable Student Attendance Management System designed to help educational institutions track, analyze, and manage attendance with precision and ease.     </p>                 
         <p class="about-text">   By replacing traditional manual registers with a secure digital platform, EduTrack Pro ensures real-time attendance tracking, improved accuracy, and transparent academic records for institutions of all sizes.  </p>
         <ul class="about-list">                    
             <li>
             <i class="fas fa-check-circle"></i> Real-time student attendance tracking</li>                       
              <li><i class="fas fa-check-circle"></i> Role-based dashboards for Admin, Teacher & Student</li>                       
               <li><i class="fas fa-check-circle"></i> Automated reports and attendance analytics</li>                        
               <li><i class="fas fa-check-circle"></i> Secure, scalable, cloud-ready system</li>                    
               </ul>                
               </div>                
               <div class="col-lg-6">                    
               <div class="row">                        
               <div class="col-md-6 mb-4">                            
               <div class="about-card">                                
               <div class="about-icon">                                    
               <i class="fas fa-bullseye"></i>                               
                </div>                                
                <h5>Our Mission</h5>                                
                <p>To modernize attendance management through intelligent automation and accurate data tracking.</p>                            
                </div>
</div>                       
 <div class="col-md-6 mb-4">                          
   <div class="about-card">                               
    <div class="about-icon">                                  
      <i class="fas fa-eye"></i>                              
        </div>                            
            <h5>Our Vision</h5>                            
                <p>To empower educational institutions with technology-driven academic management solutions.</p>                         
                   </div>                    
                   
                       </div>                 
                          </div>               
                           </div>    
                                  
                                 </div>      
                                    </div> 
                                       </section>
    <!-- Features Section -->
<section id="features" class="features-section">
    <div class="container">
        <h2 class="section-title">Powerful Features for Modern Education</h2>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <h4>Easy Attendance Marking</h4>
                    <p>Teachers can quickly mark attendance for all students with present/absent buttons and save with one click.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <h4>Attendance Reports</h4>
                    <p>Generate monthly attendance reports with percentage calculations and export to Excel format.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-lock"></i>
                    </div>
                    <h4>Secure Authentication</h4>
                    <p>Password encryption with SHA-256 hashing and role-based access control for data protection.</p>
                </div>
            </div>
        </div>

        <div class="row g-4 mt-4">
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-mobile-alt"></i>
                    </div>
                    <h4>Mobile Responsive</h4>
                    <p>Access from any device with our fully responsive web application that works on phones and tablets.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-file-export"></i>
                    </div>
                    <h4>Excel Export</h4>
                    <p>Export attendance records and reports to Excel/CSV format for offline analysis and record keeping.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-users-cog"></i>
                    </div>
                    <h4>Role-Based Dashboards</h4>
                    <p>Separate dashboards for Admins, Teachers, and Students with customized features for each role.</p>
                </div>
            </div>
        </div>
    </div>
</section>
    
    <!-- CTA Section -->
    <section class="cta-section">
        <div class="container">
            <h2 class="cta-title">Ready to Transform Your Institution?</h2>
            <p class="cta-subtitle">
                Our platform is specifically designed for schools, colleges, and universities seeking a modern, efficient, and secure attendance solution. Experience seamless attendance tracking with real-time analytics and comprehensive reporting capabilities.
            </p>
            <div class="d-flex flex-wrap justify-content-center gap-3">
               
                <a href="login.jsp" class="btn btn-outline-light btn-lg">
                    <i class="fas fa-sign-in-alt me-2"></i>Login Now
                </a>
            </div>
        </div>
    </section>
    
    <!-- Footer -->
    <footer id="contact" class="footer">
        <div class="container">
            <div class="row">
                <div class="col-lg-4 mb-5 mb-lg-0">
                    <a href="index.jsp" class="footer-logo">
                        <i class="fas fa-graduation-cap me-2"></i>EduTrack Pro
                    </a>
                    <p class="footer-description">
                        A comprehensive student attendance management system designed for modern 
                        educational institutions with a focus on efficiency, accuracy, and user experience.
                    </p>
                    <div class="social-icons">
                        <a href="#" class="social-icon"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-twitter"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-instagram"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-youtube"></i></a>
                    </div>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-5 mb-md-0">
                    <div class="footer-links">
                        <h5>Product</h5>
                        <ul>
                            <li><a href="#features">Features</a></li>
                            <li><a href="#">Pricing</a></li>
                            <li><a href="#">API</a></li>
                            <li><a href="#">Documentation</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-5 mb-md-0">
                    <div class="footer-links">
                        <h5>Company</h5>
                        <ul>
                            <li><a href="#about">About Us</a></li>
                            <li><a href="#">Careers</a></li>
                            <li><a href="#">Blog</a></li>
                            <li><a href="#">Press</a></li>
                        </ul>
                    </div>
                </div>
                
                <div class="col-lg-4 col-md-4">
                    <div class="footer-links">
                        <h5>Contact Info</h5>
                        <ul class="list-unstyled">
                            <li class="mb-3">
                                <i class="fas fa-map-marker-alt me-2"></i>
                               Mumbai
                            </li>
                            <li class="mb-3">
                                <i class="fas fa-phone me-2"></i>
                                +91 (810) 401-1403
                            </li>
                            <li class="mb-3">
                                <i class="fas fa-envelope me-2"></i>
                                support@edutrackpro.com
                            </li>
                            <li>
                                <i class="fas fa-clock me-2"></i>
                                Mon-Fri 9:00AM-6:00PM
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="copyright">
                <div class="row">
                    <div class="col-md-6 text-md-start">
                        © 2024 EduTrack Pro. All rights reserved.
                    </div>
                    <div class="col-md-6 text-md-end">
                        <a href="#" class="text-decoration-none me-3">Privacy Policy</a>
                        <a href="#" class="text-decoration-none">Terms of Service</a>
                    </div>
                </div>
                <div class="mt-2">
                    <small>MCA Project by Shravani & Sanika  </small>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    

   <script src="js/index.js"></script>
</body>
</body>
</html>
