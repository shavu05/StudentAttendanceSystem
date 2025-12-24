

<%@ page import="com.attendance.model.User" %>
<%@ page import="com.attendance.dao.UserDAO" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp?error=Please login as administrator");
        return;
    }
    
    // Get user stats
    UserDAO userDAO = new UserDAO();
    List<User> allUsers = userDAO.getAllUsers();
    int totalUsers = allUsers.size();
    int totalAdmins = 0;
    int totalTeachers = 0;
    int totalStudents = 0;
    
    for (User u : allUsers) {
        switch(u.getRole()) {
            case "admin": totalAdmins++; break;
            case "teacher": totalTeachers++; break;
            case "student": totalStudents++; break;
        }
    }
    
    // Get success/error messages
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | EduTrack Pro</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- SweetAlert2 for beautiful alerts -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        :root {
            --primary: #4361ee;
            --primary-light: #eef2ff;
            --secondary: #7209b7;
            --success: #28a745;
            --danger: #dc3545;
            --warning: #ffc107;
            --info: #17a2b8;
            --dark: #2d3748;
            --light: #f8f9fa;
            --gray: #6c757d;
        }
        
        * {
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f7ff;
            color: var(--dark);
            display: flex;
            min-height: 100vh;
            margin: 0;
            overflow-x: hidden;
        }
        
        /* ========== SIDEBAR ========== */
        .sidebar {
            width: 280px;
            background: white;
            padding: 0;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
            position: fixed;
            height: 100vh;
            display: flex;
            flex-direction: column;
            z-index: 1000;
            overflow: hidden;
        }
        
        .sidebar-header {
            padding: 25px 20px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            flex-shrink: 0;
        }
        
        .sidebar-header h3 {
            font-size: 22px;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .sidebar-header small {
            opacity: 0.9;
            font-size: 0.85rem;
            margin-top: 5px;
            display: block;
        }
        
        /* Navigation Container with Scroll */
        .sidebar-nav-container {
            flex: 1;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 20px 0;
            scrollbar-width: thin;
            scrollbar-color: rgba(0, 0, 0, 0.2) transparent;
        }
        
        .sidebar-nav-container::-webkit-scrollbar {
            width: 6px;
        }
        
        .sidebar-nav-container::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.05);
            border-radius: 10px;
        }
        
        .sidebar-nav-container::-webkit-scrollbar-thumb {
            background-color: rgba(0, 0, 0, 0.2);
            border-radius: 10px;
        }
        
        .nav-section {
            padding: 0 0 15px 0;
            border-bottom: 1px solid #e2e8f0;
            margin-bottom: 15px;
        }
        
        .nav-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        
        .nav-title {
            padding: 0 20px 10px;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #94a3b8;
            font-weight: 600;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            transition: color 0.3s;
        }
        
        .nav-title:hover {
            color: var(--primary);
        }
        
        .nav-title i {
            font-size: 10px;
            transition: transform 0.3s;
        }
        
        .nav-title i.rotated {
            transform: rotate(180deg);
        }
        
        .nav-links {
            list-style: none;
            padding: 0;
            margin: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
        }
        
        .nav-links.collapsed {
            max-height: 0;
        }
        
        .nav-link {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: #64748b;
            text-decoration: none;
            transition: all 0.3s;
            border-left: 3px solid transparent;
            cursor: pointer;
            font-size: 14px;
        }
        
        .nav-link:hover {
            background: var(--primary-light);
            color: var(--primary);
            transform: translateX(5px);
        }
        
        .nav-link.active {
            background: var(--primary-light);
            color: var(--primary);
            border-left-color: var(--primary);
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.1);
        }
        
        .nav-link i {
            width: 24px;
            font-size: 16px;
            margin-right: 12px;
        }
        
        .sidebar-user {
            padding: 20px;
            background: white;
            border-top: 1px solid #e2e8f0;
            flex-shrink: 0;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 18px;
        }
        
        .user-details h5 {
            margin: 0;
            font-size: 16px;
        }
        
        .user-details small {
            color: #64748b;
        }
        
        .logout-btn {
            color: var(--danger);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 0;
            transition: color 0.3s;
            cursor: pointer;
            background: none;
            border: none;
            width: 100%;
            font-size: 14px;
        }
        
        .logout-btn:hover {
            color: #b02a37;
        }
        
        /* ========== MAIN CONTENT ========== */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 30px;
            min-height: 100vh;
            transition: margin-left 0.3s;
        }
        
        .content-header {
            background: white;
            border-radius: 16px;
            padding: 25px 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .page-title h2 {
            font-size: 28px;
            font-weight: 700;
            color: var(--dark);
            margin: 0;
        }
        
        .page-title p {
            color: #64748b;
            margin: 5px 0 0;
        }
        
        .current-user {
            display: flex;
            align-items: center;
            gap: 15px;
            background: var(--primary-light);
            padding: 12px 20px;
            border-radius: 12px;
        }
        
        .current-user i {
            color: var(--primary);
            font-size: 24px;
        }
        
        /* ========== DASHBOARD CARDS ========== */
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            border: 1px solid #e2e8f0;
            transition: all 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(67, 97, 238, 0.15);
            border-color: rgba(67, 97, 238, 0.2);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            font-size: 24px;
        }
        
        .stat-icon.total {
            background: linear-gradient(135deg, #4361ee, #3a56d4);
            color: white;
        }
        
        .stat-icon.admin {
            background: linear-gradient(135deg, #f72585, #d90429);
            color: white;
        }
        
        .stat-icon.teacher {
            background: linear-gradient(135deg, #f8961e, #e85d04);
            color: white;
        }
        
        .stat-icon.student {
            background: linear-gradient(135deg, #4cc9f0, #118ab2);
            color: white;
        }
        
        .stat-value {
            font-size: 36px;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: #64748b;
            font-size: 16px;
        }
        
        /* ========== QUICK ACTIONS ========== */
        .quick-actions {
            background: white;
            border-radius: 16px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
        }
        
        .section-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 25px;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .action-btn {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s;
            cursor: pointer;
            color: var(--dark);
            text-decoration: none;
            display: block;
        }
        
        .action-btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(67, 97, 238, 0.15);
            border-color: rgba(67, 97, 238, 0.3);
        }
        
        .action-btn i {
            font-size: 28px;
            margin-bottom: 10px;
            display: block;
        }
        
        .action-btn.create-user i { color: var(--primary); }
        .action-btn.create-class i { color: var(--success); }
        .action-btn.reports i { color: var(--info); }
        .action-btn.settings i { color: var(--warning); }
        
        /* ========== TABLE STYLES ========== */
        .table-container {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
            border: 1px solid #e2e8f0;
            display: none;
        }
        
        .table-container.active {
            display: block;
            animation: fadeIn 0.5s ease;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .btn-add {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 12px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .btn-add:hover {
            color: white;
            box-shadow: 0 8px 25px rgba(67, 97, 238, 0.3);
        }
        
        .table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: separate;
            border-spacing: 0;
        }
        
        .table th {
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
            font-weight: 600;
            color: var(--dark);
            padding: 15px;
        }
        
        .table td {
            padding: 15px;
            vertical-align: middle;
            border-top: 1px solid #dee2e6;
        }
        
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-admin {
            background: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .badge-teacher {
            background: rgba(255, 193, 7, 0.1);
            color: #b58a00;
        }
        
        .badge-student {
            background: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: nowrap;
        }
        
        .btn-action {
            padding: 6px 12px;
            margin: 0 2px;
            border-radius: 6px;
            border: none;
            background: transparent;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            cursor: pointer;
            font-size: 12px;
        }
        
        .btn-sm-icon {
            width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
        }
        
        .btn-view {
            color: var(--primary);
            background: rgba(67, 97, 238, 0.1);
        }
        
        .btn-view:hover {
            background: rgba(67, 97, 238, 0.2);
        }
        
        .btn-edit {
            color: var(--warning);
            background: rgba(255, 193, 7, 0.1);
        }
        
        .btn-edit:hover {
            background: rgba(255, 193, 7, 0.2);
        }
        
        .btn-delete {
            color: var(--danger);
            background: rgba(220, 53, 69, 0.1);
        }
        
        .btn-delete:hover {
            background: rgba(220, 53, 69, 0.2);
        }
        
        /* ========== FILTER & SEARCH SECTION ========== */
        .filter-section {
            background: white;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            border: 1px solid #e2e8f0;
        }
        
        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .filter-title {
            font-size: 18px;
            font-weight: 600;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .search-box {
            position: relative;
            width: 300px;
        }
        
        .search-box input {
            width: 100%;
            padding: 10px 15px 10px 45px;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .search-box input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
        }
        
        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        
        .filter-controls {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            margin-top: 15px;
        }
        
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        
        .filter-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark);
            font-size: 14px;
        }
        
        .filter-group select {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            background: white;
        }
        
        .filter-group select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.1);
        }
        
        .filter-actions {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }
        
        .btn-filter {
            background: var(--primary);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 10px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .btn-filter:hover {
            background: #3a56d4;
            box-shadow: 0 4px 15px rgba(67, 97, 238, 0.2);
        }
        
        .btn-clear {
            background: #f8f9fa;
            color: var(--gray);
            border: 1px solid #e2e8f0;
            padding: 10px 20px;
            border-radius: 10px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }
        
        .btn-clear:hover {
            background: #e9ecef;
            color: var(--dark);
        }
        
        .table-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e2e8f0;
            color: #64748b;
            font-size: 14px;
        }
        
        .no-results {
            text-align: center;
            padding: 40px 20px;
            color: #94a3b8;
        }
        
        .no-results i {
            font-size: 48px;
            margin-bottom: 15px;
            color: #cbd5e1;
        }
        
        .no-results h5 {
            color: #64748b;
            margin-bottom: 10px;
        }
        
        /* ========== MANAGEMENT TABS ========== */
        .management-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 10px;
            flex-wrap: wrap;
        }
        
        .tab-btn {
            padding: 10px 20px;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            color: #64748b;
            font-weight: 500;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .tab-btn:hover {
            background: var(--primary-light);
            color: var(--primary);
        }
        
        .tab-btn.active {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }
        
        /* ========== FOOTER ========== */
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e2e8f0;
            color: #64748b;
            font-size: 14px;
        }
        
        /* ========== MOBILE MENU TOGGLE ========== */
        .menu-toggle {
            display: none;
            background: none;
            border: none;
            font-size: 24px;
            color: var(--primary);
            cursor: pointer;
            margin-right: 15px;
        }
        
        /* ========== MODAL STYLES ========== */
        .modal-content {
            border-radius: 16px;
            border: none;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }
        
        .modal-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            border-radius: 16px 16px 0 0;
            padding: 20px;
        }
        
        .modal-title {
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-label {
            font-weight: 600;
            color: var(--dark);
            margin-bottom: 8px;
        }
        
        .form-control, .form-select {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 12px 15px;
            transition: all 0.3s;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
        }
        
        .required-star {
            color: var(--danger);
        }
        
        .user-avatar-large {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 36px;
            margin: 0 auto 15px;
        }
        
        .detail-row {
            margin-bottom: 10px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        
        .detail-label {
            font-weight: 600;
            color: var(--dark);
        }
        
        .detail-value {
            color: #666;
        }
        
        .password-input-group {
            position: relative;
        }
        
        .password-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #666;
            cursor: pointer;
            z-index: 10;
        }
        
        .loading-spinner {
            text-align: center;
            padding: 40px 20px;
        }
        
        .status-badge {
            font-size: 12px;
            padding: 4px 8px;
            border-radius: 12px;
        }
        
        /* Collapsible sections on mobile by default */
        @media (max-width: 768px) {
            .nav-links {
                max-height: 0;
            }
            
            .nav-links:not(.collapsed) {
                max-height: 500px;
            }
        }
        
        /* ========== RESPONSIVE DESIGN ========== */
        @media (max-width: 992px) {
            body {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }
            
            .sidebar.active {
                transform: translateX(0);
            }
            
            .main-content {
                margin-left: 0;
                padding: 15px;
            }
            
            .menu-toggle {
                display: block;
            }
            
            .dashboard-stats {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .actions-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .filter-section {
                padding: 15px;
            }
            
            .search-box {
                width: 100%;
                margin-bottom: 15px;
            }
            
            .filter-header {
                flex-direction: column;
                align-items: stretch;
            }
            
            .filter-controls {
                flex-direction: column;
            }
            
            .filter-group {
                min-width: 100%;
            }
            
            .filter-actions {
                justify-content: flex-start;
            }
        }
        
        @media (max-width: 768px) {
            .dashboard-stats {
                grid-template-columns: 1fr;
            }
            
            .actions-grid {
                grid-template-columns: 1fr;
            }
            
            .table-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .content-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .management-tabs {
                flex-wrap: wrap;
            }
            
            .btn-action {
                padding: 4px 6px;
                font-size: 11px;
            }
            
            .btn-action i {
                font-size: 12px;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="sidebar-header">
            <h3><i class="fas fa-graduation-cap"></i> EduTrack Pro</h3>
            <small>Administration Panel</small>
        </div>
        
        <!-- Scrollable Navigation Container -->
        <div class="sidebar-nav-container">
            <div class="nav-section">
                <div class="nav-title" onclick="toggleNavSection('main-nav')">
                    Main Navigation
                    <i class="fas fa-chevron-down"></i>
                </div>
                <ul class="nav-links" id="main-nav-links">
                    <li><a class="nav-link active" data-section="dashboard" onclick="showSection('dashboard')">
                        <i class="fas fa-tachometer-alt"></i> Dashboard Overview
                    </a></li>
                </ul>
            </div>
            
            <div class="nav-section">
                <div class="nav-title" onclick="toggleNavSection('user-nav')">
                    User Management
                    <i class="fas fa-chevron-down"></i>
                </div>
                <ul class="nav-links" id="user-nav-links">
                    <li><a class="nav-link" data-section="admin" onclick="showSection('admin')">
                        <i class="fas fa-user-shield"></i> Admin Management
                    </a></li>
                    <li><a class="nav-link" data-section="teacher" onclick="showSection('teacher')">
                        <i class="fas fa-chalkboard-teacher"></i> Teacher Management
                    </a></li>
                    <li><a class="nav-link" data-section="student" onclick="showSection('student')">
                        <i class="fas fa-user-graduate"></i> Student Management
                    </a></li>
                    <li><a class="nav-link" data-section="all-users" onclick="showSection('all-users')">
                        <i class="fas fa-users"></i> All System Users
                    </a></li>
                </ul>
            </div>
            
            <!--  <div class="nav-section">
                <div class="nav-title" onclick="toggleNavSection('system-nav')">
                   
                    <i class="fas fa-chevron-down"></i>
                </div>
                <ul class="nav-links" id="system-nav-links">
                    <li><a class="nav-link" data-section="classes" onclick="showSection('classes')">
                        <i class="fas fa-chalkboard"></i> 
                    </a></li>
                    <li><a class="nav-link" data-section="attendance" onclick="showSection('attendance')">
                        <i class="fas fa-clipboard-check"></i> 
                    </a></li>
                    <li><a class="nav-link" data-section="reports" onclick="showSection('reports')">
                        <i class="fas fa-chart-bar"></i> 
                    </a></li>
                    <li><a class="nav-link" data-section="settings" onclick="showSection('settings')">
                        <i class="fas fa-cog"></i> 
                    </a></li>
                </ul>
            </div> -->
        </div>
        
        <div class="sidebar-user">
            <div class="user-info">
                <div class="user-avatar">
                    <%= user.getFullName().charAt(0) %>
                </div>
                <div class="user-details">
                    <h5><%= user.getFullName() %></h5>
                    <small>Administrator</small>
                </div>
            </div>
            <button class="logout-btn" onclick="logout()">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="main-content">
        <!-- Content Header -->
        <div class="content-header">
            <div class="d-flex align-items-center">
                <button class="menu-toggle" id="menuToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <div class="page-title">
                    <h2 id="page-title">Dashboard Overview</h2>
                    <p id="page-subtitle">Welcome back, <%= user.getFullName() %></p>
                </div>
            </div>
            <div class="current-user">
                <i class="fas fa-user-circle"></i>
                <div>
                    <div class="fw-bold"><%= user.getFullName() %></div>
                    <div class="small">Administrator</div>
                </div>
            </div>
        </div>
        
        <!-- Dashboard Content -->
        <div id="dashboard-content">
            <!-- Dashboard Statistics -->
            <div class="dashboard-stats">
                <div class="stat-card">
                    <div class="stat-icon total">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="stat-value"><%= totalUsers %></div>
                    <div class="stat-label">Total Users</div>
                    <small class="text-success"> </small>
                </div>
                <div class="stat-card">
                    <div class="stat-icon admin">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="stat-value"><%= totalAdmins %></div>
                    <div class="stat-label">Administrators</div>
                    <small>System Managers</small>
                </div>
                <div class="stat-card">
                    <div class="stat-icon teacher">
                        <i class="fas fa-chalkboard-teacher"></i>
                    </div>
                    <div class="stat-value"><%= totalTeachers %></div>
                    <div class="stat-label">Teachers</div>
                    <small>Attendance Markers</small>
                </div>
                <div class="stat-card">
                    <div class="stat-icon student">
                        <i class="fas fa-user-graduate"></i>
                    </div>
                    <div class="stat-value"><%= totalStudents %></div>
                    <div class="stat-label">Students</div>
                    <small>Attendance Tracked</small>
                </div>
            </div>
            
            <!-- Quick Actions -->
            <div class="quick-actions">
                <div class="section-title">
                    <i class="fas fa-bolt"></i> Quick Actions
                </div>
                <div class="actions-grid">
                    <div class="action-btn create-user" onclick="showAddUserModal()">
                        <i class="fas fa-user-plus"></i>
                        <span>Add New User</span>
                        <small class="text-muted">Admin, Teacher or Student</small>
                    </div>
                    <div class="action-btn create-class" onclick="showSection('classes')">
                        <i class="fas fa-chalkboard"></i>
                        <span>Manage Classes</span>
                        <small class="text-muted">Add/View/Update Classes</small>
                    </div>
                    <div class="action-btn reports" onclick="showSection('reports')">
                        <i class="fas fa-chart-bar"></i>
                        <span>Generate Reports</span>
                        <small class="text-muted">Attendance & Analytics</small>
                    </div>
                    <div class="action-btn settings" onclick="showSection('settings')">
                        <i class="fas fa-cog"></i>
                        <span>System Settings</span>
                        <small class="text-muted">Configure Preferences</small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- ========== ADMIN MANAGEMENT TABLE ========== -->
        <div id="admin-management" class="table-container">
            <div class="table-header">
                <div>
                    <h4><i class="fas fa-user-shield"></i> Admin Management</h4>
                    <p class="text-muted mb-0">Add, View, Update, Delete Administrators</p>
                </div>
                <button class="btn-add" onclick="showAddUserModal('admin')">
                    <i class="fas fa-plus"></i> Add Admin
                </button>
            </div>
            
            <!-- Filter & Search Section -->
            <div class="filter-section">
                <div class="filter-header">
                    <div class="filter-title">
                        <i class="fas fa-filter"></i> Filter & Search
                    </div>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="adminSearch" placeholder="Search by name, username, email or phone..." 
                               onkeyup="filterTable('admin')">
                    </div>
                </div>
                
                <div class="filter-controls">
                    <div class="filter-group">
                        <label><i class="fas fa-user-tag"></i> Status</label>
                        <select id="adminStatusFilter" onchange="filterTable('admin')">
                            <option value="all">All Status</option>
                            <option value="active">Active Only</option>
                            <option value="inactive">Inactive Only</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-sort"></i> Sort By</label>
                        <select id="adminSortBy" onchange="sortTable('admin')">
                            <option value="id">ID</option>
                            <option value="name">Name (A-Z)</option>
                            <option value="name_desc">Name (Z-A)</option>
                            <option value="username">Username (A-Z)</option>
                            <option value="email">Email (A-Z)</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-eye"></i> Items Per Page</label>
                        <select id="adminPageSize" onchange="updatePagination('admin')">
                            <option value="10">10 items</option>
                            <option value="25">25 items</option>
                            <option value="50">50 items</option>
                            <option value="100">100 items</option>
                        </select>
                    </div>
                    
                    <div class="filter-actions">
                        <button class="btn-clear" onclick="clearFilters('admin')">
                            <i class="fas fa-eraser"></i> Clear
                        </button>
                        <button class="btn-filter" onclick="exportToExcel('admin')">
                            <i class="fas fa-file-excel"></i> Export
                        </button>
                    </div>
                </div>
                
                <div class="table-info" id="adminTableInfo">
                    Showing <span id="adminShowingCount">0</span> of <span id="adminTotalCount">0</span> administrators
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="adminTableBody">
                        <% for (User u : allUsers) { 
                            if ("admin".equals(u.getRole())) { %>
                        <tr data-id="<%= u.getId() %>" 
                            data-name="<%= u.getFullName().toLowerCase() %>"
                            data-username="<%= u.getUsername().toLowerCase() %>"
                            data-email="<%= u.getEmail().toLowerCase() %>"
                            data-phone="<%= u.getPhone() != null ? u.getPhone().toLowerCase() : "" %>"
                            data-status="<%= u.isActive() ? "active" : "inactive" %>">
                            <td><%= u.getId() %></td>
                            <td><strong><%= u.getUsername() %></strong></td>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getPhone() != null ? u.getPhone() : "N/A" %></td>
                            <td>
                                <span class="badge badge-admin">ADMIN</span>
                            </td>
                            <td>
                                <% if (u.isActive()) { %>
                                    <span class="badge bg-success">Active</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Inactive</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewUser(<%= u.getId() %>)" title="View">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn-action btn-edit" onclick="editUser(<%= u.getId() %>)" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn-action btn-delete" onclick="deleteUser(<%= u.getId() %>)" title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
                
                <!-- No Results Message -->
                <div id="adminNoResults" class="no-results" style="display: none;">
                    <i class="fas fa-user-shield"></i>
                    <h5>No Administrators Found</h5>
                    <p>Try adjusting your search or filter criteria</p>
                </div>
                
                <!-- Pagination -->
                <nav id="adminPagination" class="mt-3">
                    <ul class="pagination justify-content-center">
                        <!-- Pagination will be generated by JavaScript -->
                    </ul>
                </nav>
            </div>
        </div>
        
        <!-- ========== TEACHER MANAGEMENT TABLE ========== -->
        <div id="teacher-management" class="table-container">
            <div class="table-header">
                <div>
                    <h4><i class="fas fa-chalkboard-teacher"></i> Teacher Management</h4>
                    <p class="text-muted mb-0">Add, View, Update, Delete Teachers</p>
                </div>
                <button class="btn-add" onclick="showAddUserModal('teacher')">
                    <i class="fas fa-plus"></i> Add Teacher
                </button>
            </div>
            
            <!-- Filter & Search Section -->
            <div class="filter-section">
                <div class="filter-header">
                    <div class="filter-title">
                        <i class="fas fa-filter"></i> Filter & Search
                    </div>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="teacherSearch" placeholder="Search by name, username, email, department or subjects..." 
                               onkeyup="filterTable('teacher')">
                    </div>
                </div>
                
                <div class="filter-controls">
                    <div class="filter-group">
                        <label><i class="fas fa-user-tag"></i> Status</label>
                        <select id="teacherStatusFilter" onchange="filterTable('teacher')">
                            <option value="all">All Status</option>
                            <option value="active">Active Only</option>
                            <option value="inactive">Inactive Only</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-building"></i> Department</label>
                        <select id="teacherDeptFilter" onchange="filterTable('teacher')">
                            <option value="all">All Departments</option>
                            <% 
                                java.util.HashSet<String> teacherDepts = new java.util.HashSet<>();
                                for (User u : allUsers) {
                                    if ("teacher".equals(u.getRole()) && u.getDepartment() != null) {
                                        teacherDepts.add(u.getDepartment());
                                    }
                                }
                                for (String dept : teacherDepts) {
                            %>
                            <option value="<%= dept %>"><%= dept %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-sort"></i> Sort By</label>
                        <select id="teacherSortBy" onchange="sortTable('teacher')">
                            <option value="id">ID</option>
                            <option value="name">Name (A-Z)</option>
                            <option value="name_desc">Name (Z-A)</option>
                            <option value="dept">Department (A-Z)</option>
                            <option value="username">Username (A-Z)</option>
                        </select>
                    </div>
                    
                    <div class="filter-actions">
                        <button class="btn-clear" onclick="clearFilters('teacher')">
                            <i class="fas fa-eraser"></i> Clear
                        </button>
                        <button class="btn-filter" onclick="exportToExcel('teacher')">
                            <i class="fas fa-file-excel"></i> Export
                        </button>
                    </div>
                </div>
                
                <div class="table-info" id="teacherTableInfo">
                    Showing <span id="teacherShowingCount">0</span> of <span id="teacherTotalCount">0</span> teachers
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Department</th>
                            <th>Subjects</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="teacherTableBody">
                        <% for (User u : allUsers) { 
                            if ("teacher".equals(u.getRole())) { %>
                        <tr data-id="<%= u.getId() %>" 
                            data-name="<%= u.getFullName().toLowerCase() %>"
                            data-username="<%= u.getUsername().toLowerCase() %>"
                            data-email="<%= u.getEmail().toLowerCase() %>"
                            data-department="<%= u.getDepartment() != null ? u.getDepartment().toLowerCase() : "" %>"
                            data-subjects="<%= u.getSubjects() != null ? u.getSubjects().toLowerCase() : "" %>"
                            data-status="<%= u.isActive() ? "active" : "inactive" %>">
                            <td><%= u.getId() %></td>
                            <td><strong><%= u.getUsername() %></strong></td>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getDepartment() != null ? u.getDepartment() : "N/A" %></td>
                            <td><%= u.getSubjects() != null ? u.getSubjects() : "N/A" %></td>
                            <td>
                                <% if (u.isActive()) { %>
                                    <span class="badge bg-success">Active</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Inactive</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewUser(<%= u.getId() %>)" title="View">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn-action btn-edit" onclick="editUser(<%= u.getId() %>)" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn-action btn-delete" onclick="deleteUser(<%= u.getId() %>)" title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
                
                <!-- No Results Message -->
                <div id="teacherNoResults" class="no-results" style="display: none;">
                    <i class="fas fa-chalkboard-teacher"></i>
                    <h5>No Teachers Found</h5>
                    <p>Try adjusting your search or filter criteria</p>
                </div>
                
                <!-- Pagination -->
                <nav id="teacherPagination" class="mt-3">
                    <ul class="pagination justify-content-center">
                        <!-- Pagination will be generated by JavaScript -->
                    </ul>
                </nav>
            </div>
        </div>
        
        <!-- ========== STUDENT MANAGEMENT TABLE ========== -->
        <div id="student-management" class="table-container">
            <div class="table-header">
                <div>
                    <h4><i class="fas fa-user-graduate"></i> Student Management</h4>
                    <p class="text-muted mb-0">Add, View, Update, Delete Students</p>
                </div>
                <button class="btn-add" onclick="showAddUserModal('student')">
                    <i class="fas fa-plus"></i> Add Student
                </button>
            </div>
            
            <!-- Filter & Search Section -->
            <div class="filter-section">
                <div class="filter-header">
                    <div class="filter-title">
                        <i class="fas fa-filter"></i> Filter & Search
                    </div>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="studentSearch" placeholder="Search by name, username, email, roll no, class or department..." 
                               onkeyup="filterTable('student')">
                    </div>
                </div>
                
                <div class="filter-controls">
                    <div class="filter-group">
                        <label><i class="fas fa-user-tag"></i> Status</label>
                        <select id="studentStatusFilter" onchange="filterTable('student')">
                            <option value="all">All Status</option>
                            <option value="active">Active Only</option>
                            <option value="inactive">Inactive Only</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-building"></i> Department</label>
                        <select id="studentDeptFilter" onchange="filterTable('student')">
                            <option value="all">All Departments</option>
                            <% 
                                java.util.HashSet<String> studentDepts = new java.util.HashSet<>();
                                for (User u : allUsers) {
                                    if ("student".equals(u.getRole()) && u.getDepartment() != null) {
                                        studentDepts.add(u.getDepartment());
                                    }
                                }
                                for (String dept : studentDepts) {
                            %>
                            <option value="<%= dept %>"><%= dept %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-users"></i> Class</label>
                        <select id="studentClassFilter" onchange="filterTable('student')">
                            <option value="all">All Classes</option>
                            <% 
                                java.util.HashSet<String> studentClasses = new java.util.HashSet<>();
                                for (User u : allUsers) {
                                    if ("student".equals(u.getRole()) && u.getClassName() != null) {
                                        studentClasses.add(u.getClassName());
                                    }
                                }
                                for (String className : studentClasses) {
                            %>
                            <option value="<%= className %>"><%= className %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="filter-actions">
                        <button class="btn-clear" onclick="clearFilters('student')">
                            <i class="fas fa-eraser"></i> Clear
                        </button>
                        <button class="btn-filter" onclick="exportToExcel('student')">
                            <i class="fas fa-file-excel"></i> Export
                        </button>
                    </div>
                </div>
                
                <div class="table-info" id="studentTableInfo">
                    Showing <span id="studentShowingCount">0</span> of <span id="studentTotalCount">0</span> students
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Roll No</th>
                            <th>Class</th>
                            <th>Department</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="studentTableBody">
                        <% for (User u : allUsers) { 
                            if ("student".equals(u.getRole())) { %>
                        <tr data-id="<%= u.getId() %>" 
                            data-name="<%= u.getFullName().toLowerCase() %>"
                            data-username="<%= u.getUsername().toLowerCase() %>"
                            data-email="<%= u.getEmail().toLowerCase() %>"
                            data-rollno="<%= u.getRollNo() != null ? u.getRollNo().toLowerCase() : "" %>"
                            data-class="<%= u.getClassName() != null ? u.getClassName().toLowerCase() : "" %>"
                            data-department="<%= u.getDepartment() != null ? u.getDepartment().toLowerCase() : "" %>"
                            data-status="<%= u.isActive() ? "active" : "inactive" %>">
                            <td><%= u.getId() %></td>
                            <td><strong><%= u.getUsername() %></strong></td>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><%= u.getRollNo() != null ? u.getRollNo() : "N/A" %></td>
                            <td><%= u.getClassName() != null ? u.getClassName() : "N/A" %></td>
                            <td><%= u.getDepartment() != null ? u.getDepartment() : "N/A" %></td>
                            <td>
                                <% if (u.isActive()) { %>
                                    <span class="badge bg-success">Active</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Inactive</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewUser(<%= u.getId() %>)" title="View">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn-action btn-edit" onclick="editUser(<%= u.getId() %>)" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn-action btn-delete" onclick="deleteUser(<%= u.getId() %>)" title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
                
                <!-- No Results Message -->
                <div id="studentNoResults" class="no-results" style="display: none;">
                    <i class="fas fa-user-graduate"></i>
                    <h5>No Students Found</h5>
                    <p>Try adjusting your search or filter criteria</p>
                </div>
                
                <!-- Pagination -->
                <nav id="studentPagination" class="mt-3">
                    <ul class="pagination justify-content-center">
                        <!-- Pagination will be generated by JavaScript -->
                    </ul>
                </nav>
            </div>
        </div>
        
        <!-- ========== ALL USERS TABLE ========== -->
        <div id="all-users" class="table-container">
            <div class="table-header">
                <div>
                    <h4><i class="fas fa-users"></i> All System Users</h4>
                    <p class="text-muted mb-0">View all users in the system</p>
                </div>
                <button class="btn-add" onclick="showAddUserModal()">
                    <i class="fas fa-plus"></i> Add New User
                </button>
            </div>
            
            <!-- Filter & Search Section -->
            <div class="filter-section">
                <div class="filter-header">
                    <div class="filter-title">
                        <i class="fas fa-filter"></i> Filter & Search
                    </div>
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="allUsersSearch" placeholder="Search by name, username, email, roll no, class or department..." 
                               onkeyup="filterTable('all-users')">
                    </div>
                </div>
                
                <div class="filter-controls">
                    <div class="filter-group">
                        <label><i class="fas fa-user-tag"></i> Role</label>
                        <select id="allUsersRoleFilter" onchange="filterTable('all-users')">
                            <option value="all">All Roles</option>
                            <option value="admin">Admin Only</option>
                            <option value="teacher">Teacher Only</option>
                            <option value="student">Student Only</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-user-tag"></i> Status</label>
                        <select id="allUsersStatusFilter" onchange="filterTable('all-users')">
                            <option value="all">All Status</option>
                            <option value="active">Active Only</option>
                            <option value="inactive">Inactive Only</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><i class="fas fa-sort"></i> Sort By</label>
                        <select id="allUsersSortBy" onchange="sortTable('all-users')">
                            <option value="id">ID</option>
                            <option value="name">Name (A-Z)</option>
                            <option value="name_desc">Name (Z-A)</option>
                            <option value="role">Role</option>
                            <option value="username">Username (A-Z)</option>
                        </select>
                    </div>
                    
                    <div class="filter-actions">
                        <button class="btn-clear" onclick="clearFilters('all-users')">
                            <i class="fas fa-eraser"></i> Clear
                        </button>
                       <!--  <button class="btn-filter" onclick="exportToExcel('all-users')">
                            <i class="fas fa-file-excel"></i> 
                        </button>--> 
                    </div>
                </div>
                
                <div class="table-info" id="allUsersTableInfo">
                    Showing <span id="allUsersShowingCount">0</span> of <span id="allUsersTotalCount">0</span> users
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Username</th>
                            <th>Full Name</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Roll No</th>
                            <th>Class</th>
                            <th>Department</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="allUsersTableBody">
                        <% for (User u : allUsers) { %>
                        <tr data-id="<%= u.getId() %>" 
                            data-name="<%= u.getFullName().toLowerCase() %>"
                            data-username="<%= u.getUsername().toLowerCase() %>"
                            data-email="<%= u.getEmail().toLowerCase() %>"
                            data-rollno="<%= u.getRollNo() != null ? u.getRollNo().toLowerCase() : "" %>"
                            data-class="<%= u.getClassName() != null ? u.getClassName().toLowerCase() : "" %>"
                            data-department="<%= u.getDepartment() != null ? u.getDepartment().toLowerCase() : "" %>"
                            data-role="<%= u.getRole() %>"
                            data-status="<%= u.isActive() ? "active" : "inactive" %>">
                            <td><%= u.getId() %></td>
                            <td><strong><%= u.getUsername() %></strong></td>
                            <td><%= u.getFullName() %></td>
                            <td><%= u.getEmail() %></td>
                            <td>
                                <% if ("admin".equals(u.getRole())) { %>
                                    <span class="badge badge-admin">ADMIN</span>
                                <% } else if ("teacher".equals(u.getRole())) { %>
                                    <span class="badge badge-teacher">TEACHER</span>
                                <% } else { %>
                                    <span class="badge badge-student">STUDENT</span>
                                <% } %>
                            </td>
                            <td><%= u.getRollNo() != null ? u.getRollNo() : "N/A" %></td>
                            <td><%= u.getClassName() != null ? u.getClassName() : "N/A" %></td>
                            <td><%= u.getDepartment() != null ? u.getDepartment() : "N/A" %></td>
                            <td>
                                <% if (u.isActive()) { %>
                                    <span class="badge bg-success">Active</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Inactive</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-action btn-view" onclick="viewUser(<%= u.getId() %>)" title="View">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn-action btn-edit" onclick="editUser(<%= u.getId() %>)" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn-action btn-delete" onclick="deleteUser(<%= u.getId() %>)" title="Delete">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <!-- No Results Message -->
                <div id="allUsersNoResults" class="no-results" style="display: none;">
                    <i class="fas fa-users"></i>
                    <h5>No Users Found</h5>
                    <p>Try adjusting your search or filter criteria</p>
                </div>
                
                <!-- Pagination -->
                <nav id="allUsersPagination" class="mt-3">
                    <ul class="pagination justify-content-center">
                        <!-- Pagination will be generated by JavaScript -->
                    </ul>
                </nav>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="footer">
            <div class="row">
                <div class="col-md-6">
                    <p><i class="fas fa-graduation-cap text-primary me-2"></i> <strong>EduTrack Pro</strong> - Attendance Management System</p>
                </div>
                <div class="col-md-6 text-end">
                    <p><i class="fas fa-user-graduate me-2"></i> MCA Project | Admin Panel v1.0</p>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Add User Modal -->
    <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addUserModalLabel">
                        <i class="fas fa-user-plus me-2"></i> Add New User
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addUserForm">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Role <span class="required-star">*</span></label>
                                    <select class="form-select" name="role" id="userRole" required onchange="toggleFields()">
                                        <option value="">Select Role</option>
                                        <option value="admin">Administrator</option>
                                        <option value="teacher">Teacher</option>
                                        <option value="student">Student</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Full Name <span class="required-star">*</span></label>
                                    <input type="text" class="form-control" name="fullName" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Username <span class="required-star">*</span></label>
                                    <input type="text" class="form-control" name="username" required>
                                    <small class="text-muted">Must be unique</small>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Password <span class="required-star">*</span></label>
                                    <div class="password-input-group">
                                        <input type="password" class="form-control" name="password" id="passwordField" required>
                                        <button type="button" class="password-toggle" onclick="togglePassword('passwordField')">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                    <small class="text-muted">Minimum 6 characters</small>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Email <span class="required-star">*</span></label>
                                    <input type="email" class="form-control" name="email" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Phone Number</label>
                                    <input type="tel" class="form-control" name="phone">
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Department</label>
                                    <select class="form-select" name="department">
                                        <option value="">Select Department</option>
                                        <option value="Computer Science">Computer Science</option>
                                        <option value="Mathematics">Mathematics</option>
                                        <option value="Physics">Physics</option>
                                        <option value="Chemistry">Chemistry</option>
                                        <option value="Biology">Biology</option>
                                        <option value="English">English</option>
                                        <option value="History">History</option>
                                        <option value="Administration">Administration</option>
                                    </select>
                                </div>
                                
                                <div id="studentFields" style="display: none;">
                                    <div class="mb-3">
                                        <label class="form-label">Roll Number <span class="required-star">*</span></label>
                                        <input type="text" class="form-control" name="rollNo">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Class/Year <span class="required-star">*</span></label>
                                        <select class="form-select" name="className">
                                            <option value="">Select Class</option>
                                            <option value="1st Year">1st Year</option>
                                            <option value="2nd Year">2nd Year</option>
                                            <option value="3rd Year">3rd Year</option>
                                            <option value="4th Year">4th Year</option>
                                            <option value="5th Year">5th Year</option>
                                            <option value="Class 9">Class 9</option>
                                            <option value="Class 10">Class 10</option>
                                            <option value="Class 11">Class 11</option>
                                            <option value="Class 12">Class 12</option>
                                        </select>
                                    </div>
                                </div>
                                
                                <div id="teacherFields" style="display: none;">
                                    <div class="mb-3">
                                        <label class="form-label">Subjects (comma separated)</label>
                                        <input type="text" class="form-control" name="subjects" placeholder="e.g., Mathematics, Physics">
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" name="isActive" id="isActive" checked>
                                        <label class="form-check-label" for="isActive">
                                            Active User
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary" id="addUserBtn">
                                <i class="fas fa-user-plus me-2"></i> Add User
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <!-- View User Modal -->
<div class="modal fade" id="viewUserModal" tabindex="-1" aria-labelledby="viewUserModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="viewUserModalLabel">
                    <i class="fas fa-user-circle me-2"></i> User Details
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="userDetailsBody">
                <div class="loading-spinner" id="viewUserLoading">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading user details...</p>
                </div>
                <div id="userDetailsContent" style="display: none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="editFromViewBtn" onclick="editUserFromView()">
                    <i class="fas fa-edit me-2"></i> Edit User
                </button>
            </div>
        </div>
    </div>
</div>
    
    <!-- Edit User Modal -->
    <div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editUserModalLabel">
                        <i class="fas fa-user-edit me-2"></i> Edit User
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editUserForm">
                        <input type="hidden" id="editUserId" name="id">
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Role <span class="required-star">*</span></label>
                                    <select class="form-select" name="role" id="editUserRole" required onchange="toggleEditFields()">
                                        <option value="admin">Administrator</option>
                                        <option value="teacher">Teacher</option>
                                        <option value="student">Student</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Full Name <span class="required-star">*</span></label>
                                    <input type="text" class="form-control" id="editFullName" name="fullName" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Username <span class="required-star">*</span></label>
                                    <input type="text" class="form-control" id="editUsername" name="username" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">New Password</label>
                                    <div class="password-input-group">
                                        <input type="password" class="form-control" id="editPassword" name="password">
                                        <button type="button" class="password-toggle" onclick="togglePassword('editPassword')">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                    <small class="text-muted">Leave blank to keep current password</small>
                                </div>
                            </div>
                            
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label">Email <span class="required-star">*</span></label>
                                    <input type="email" class="form-control" id="editEmail" name="email" required>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Phone Number</label>
                                    <input type="tel" class="form-control" id="editPhone" name="phone">
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">Department</label>
                                    <select class="form-select" id="editDepartment" name="department">
                                        <option value="">Select Department</option>
                                        <option value="Computer Science">Computer Science</option>
                                        <option value="Mathematics">Mathematics</option>
                                        <option value="Physics">Physics</option>
                                        <option value="Chemistry">Chemistry</option>
                                        <option value="Biology">Biology</option>
                                        <option value="English">English</option>
                                        <option value="History">History</option>
                                        <option value="Administration">Administration</option>
                                    </select>
                                </div>
                                
                                <div id="editStudentFields" style="display: none;">
                                    <div class="mb-3">
                                        <label class="form-label">Roll Number</label>
                                        <input type="text" class="form-control" id="editRollNo" name="rollNo">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Class/Year</label>
                                        <select class="form-select" id="editClassName" name="className">
                                            <option value="">Select Class</option>
                                            <option value="1st Year">1st Year</option>
                                            <option value="2nd Year">2nd Year</option>
                                            <option value="3rd Year">3rd Year</option>
                                            <option value="4th Year">4th Year</option>
                                            <option value="5th Year">5th Year</option>
                                            <option value="Class 9">Class 9</option>
                                            <option value="Class 10">Class 10</option>
                                            <option value="Class 11">Class 11</option>
                                            <option value="Class 12">Class 12</option>
                                        </select>
                                    </div>
                                </div>
                                
                                <div id="editTeacherFields" style="display: none;">
                                    <div class="mb-3">
                                        <label class="form-label">Subjects (comma separated)</label>
                                        <input type="text" class="form-control" id="editSubjects" name="subjects" placeholder="e.g., Mathematics, Physics">
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" role="switch" 
                                               id="editIsActive" name="isActive" checked>
                                        <label class="form-check-label" for="editIsActive">
                                            User Status: <span id="statusText">Active</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary" id="updateUserBtn">
                                <i class="fas fa-save me-2"></i> Update User
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

<!-- Bootstrap JS Bundle with Popper -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>/* ========================================
EDUTRACK PRO - ADMIN DASHBOARD JAVASCRIPT
Version: 1.0.0 - Eclipse/JSP Compatible
No ES6 Syntax - Pure JavaScript
======================================== */

var currentUserId = null;
var tableState = {
 'admin': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', statusFilter: 'all', sortBy: 'id' },
 'teacher': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', statusFilter: 'all', deptFilter: 'all', sortBy: 'id' },
 'student': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', statusFilter: 'all', deptFilter: 'all', classFilter: 'all', sortBy: 'id' },
 'all-users': { currentPage: 1, pageSize: 10, filteredRows: [], totalRows: 0, searchTerm: '', roleFilter: 'all', statusFilter: 'all', sortBy: 'id' }
};

document.addEventListener('DOMContentLoaded', function() {
 initializeAll();
});

function initializeAll() {
 initializeTable('admin');
 initializeTable('teacher');
 initializeTable('student');
 initializeTable('all-users');
 showSection('dashboard');
 setupFormHandlers();
 setupMobileMenu();
 adjustNavigationForMobile();
 window.addEventListener('resize', adjustNavigationForMobile);
}

function setupFormHandlers() {
 document.getElementById('addUserForm').addEventListener('submit', function(e) {
     e.preventDefault();
     addUser();
 });
 
 document.getElementById('editUserForm').addEventListener('submit', function(e) {
     e.preventDefault();
     updateUser();
 });
 
 document.getElementById('editIsActive').addEventListener('change', function() {
     document.getElementById('statusText').textContent = this.checked ? 'Active' : 'Inactive';
 });
}

function setupMobileMenu() {
 var menuToggle = document.getElementById('menuToggle');
 var sidebar = document.querySelector('.sidebar');
 
 if (menuToggle && sidebar) {
     menuToggle.addEventListener('click', function(e) {
         e.stopPropagation();
         sidebar.classList.toggle('active');
     });
     
     document.addEventListener('click', function(event) {
         if (window.innerWidth <= 992 && sidebar.classList.contains('active') && 
             !sidebar.contains(event.target) && !menuToggle.contains(event.target)) {
             sidebar.classList.remove('active');
         }
     });
 }
}

function initializeTable(tableType) {
 var tableBody = document.getElementById(tableType + 'TableBody');
 if (!tableBody) return;
 
 var rows = [];
 var allRows = tableBody.querySelectorAll('tr');
 for (var i = 0; i < allRows.length; i++) {
     rows.push(allRows[i]);
 }
 
 tableState[tableType].totalRows = rows.length;
 tableState[tableType].filteredRows = rows;
 filterTable(tableType);
}

function addUser() {
 var form = document.getElementById("addUserForm");
 var formData = new FormData(form);
 
 var username = formData.get('username');
 var password = formData.get('password');
 var email = formData.get('email');
 var fullName = formData.get('fullName');
 var role = formData.get('role');
 
 if (!username || !password || !email || !fullName || !role) {
     Swal.fire("Validation Error", "Please fill all required fields", "warning");
     return;
 }
 
 if (password.length < 6) {
     Swal.fire("Validation Error", "Password must be at least 6 characters", "warning");
     return;
 }
 
 var isActiveCheckbox = document.querySelector('#addUserForm input[name="isActive"]');
 formData.set('isActive', isActiveCheckbox && isActiveCheckbox.checked ? 'true' : 'false');
 
 var data = new URLSearchParams(formData);
 data.append("action", "add");
 
 Swal.fire({
     title: 'Adding User...',
     allowOutsideClick: false,
     didOpen: function() { Swal.showLoading(); }
 });

 fetch("UserServlet", {
     method: "POST",
     headers: { "Content-Type": "application/x-www-form-urlencoded" },
     body: data.toString()
 })
 .then(function(res) { return res.json(); })
 .then(function(result) {
     Swal.close();
     if (result.success) {
         Swal.fire({ icon: "success", title: "Success!", text: result.message, timer: 2000 })
             .then(function() { location.reload(); });
     } else {
         Swal.fire("Error", result.message, "error");
     }
 })
 .catch(function(err) {
     console.error("Add User Error:", err);
     Swal.close();
     Swal.fire("Error", "Failed to add user", "error");
 });
}

function viewUser(id) {
 currentUserId = id;
 var modal = new bootstrap.Modal(document.getElementById('viewUserModal'));
 document.getElementById('viewUserLoading').style.display = 'block';
 document.getElementById('userDetailsContent').style.display = 'none';
 modal.show();
 
 fetch("UserServlet?action=getUser&id=" + id)
 .then(function(res) { return res.json(); })
 .then(function(user) {
     document.getElementById('viewUserLoading').style.display = 'none';
     document.getElementById('userDetailsContent').style.display = 'block';
     
     var roleClass = user.role === 'admin' ? 'badge-admin' : (user.role === 'teacher' ? 'badge-teacher' : 'badge-student');
     var html = '<div class="text-center mb-4"><div class="user-avatar-large">' + user.fullName.charAt(0).toUpperCase() + '</div>' +
         '<h4 class="mb-1">' + user.fullName + '</h4><span class="badge ' + roleClass + '">' + user.role.toUpperCase() + '</span></div>' +
         '<div class="row"><div class="col-md-6">' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-id-badge me-2"></i>User ID</div><div class="detail-value">' + user.id + '</div></div>' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-user me-2"></i>Username</div><div class="detail-value">' + user.username + '</div></div>' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-envelope me-2"></i>Email</div><div class="detail-value">' + user.email + '</div></div>' +
         '<div class="detail-row"><div class="detail-label"><i class="fas fa-phone me-2"></i>Phone</div><div class="detail-value">' + (user.phone || 'N/A') + '</div></div></div>' +
         '<div class="col-md-6"><div class="detail-row"><div class="detail-label"><i class="fas fa-building me-2"></i>Department</div><div class="detail-value">' + (user.department || 'N/A') + '</div></div>';
     
     if (user.role === 'teacher') {
         html += '<div class="detail-row"><div class="detail-label"><i class="fas fa-book me-2"></i>Subjects</div><div class="detail-value">' + (user.subjects || 'N/A') + '</div></div>';
     }
     if (user.role === 'student') {
         html += '<div class="detail-row"><div class="detail-label"><i class="fas fa-id-card me-2"></i>Roll Number</div><div class="detail-value">' + (user.rollNo || 'N/A') + '</div></div>' +
             '<div class="detail-row"><div class="detail-label"><i class="fas fa-users me-2"></i>Class</div><div class="detail-value">' + (user.className || 'N/A') + '</div></div>';
     }
     
     html += '<div class="detail-row"><div class="detail-label"><i class="fas fa-toggle-on me-2"></i>Status</div><div class="detail-value">' +
         '<span class="badge ' + (user.active ? 'bg-success' : 'bg-danger') + '">' + (user.active ? 'Active' : 'Inactive') + '</span></div></div></div></div>';
     
     document.getElementById('userDetailsContent').innerHTML = html;
 })
 .catch(function(err) {
     console.error("View User Error:", err);
     Swal.fire("Error", "Failed to load user details", "error");
     modal.hide();
 });
}

function editUser(id) {
 currentUserId = id;
 var modal = new bootstrap.Modal(document.getElementById('editUserModal'));
 
 fetch("UserServlet?action=getUser&id=" + id)
 .then(function(res) { return res.json(); })
 .then(function(user) {
     document.getElementById('editUserId').value = user.id;
     document.getElementById('editUserRole').value = user.role;
     document.getElementById('editFullName').value = user.fullName;
     document.getElementById('editUsername').value = user.username;
     document.getElementById('editEmail').value = user.email;
     document.getElementById('editPhone').value = user.phone || '';
     document.getElementById('editDepartment').value = user.department || '';
     document.getElementById('editIsActive').checked = user.active;
     document.getElementById('statusText').textContent = user.active ? 'Active' : 'Inactive';
     
     if (user.role === 'student') {
         document.getElementById('editStudentFields').style.display = 'block';
         document.getElementById('editTeacherFields').style.display = 'none';
         document.getElementById('editRollNo').value = user.rollNo || '';
         document.getElementById('editClassName').value = user.className || '';
     } else if (user.role === 'teacher') {
         document.getElementById('editTeacherFields').style.display = 'block';
         document.getElementById('editStudentFields').style.display = 'none';
         document.getElementById('editSubjects').value = user.subjects || '';
     } else {
         document.getElementById('editStudentFields').style.display = 'none';
         document.getElementById('editTeacherFields').style.display = 'none';
     }
     modal.show();
 })
 .catch(function(err) {
     console.error("Edit User Error:", err);
     Swal.fire("Error", "Failed to load user data", "error");
 });
}

function editUserFromView() {
 var viewModal = bootstrap.Modal.getInstance(document.getElementById('viewUserModal'));
 if (viewModal) viewModal.hide();
 setTimeout(function() { editUser(currentUserId); }, 300);
}

function updateUser() {
 var form = document.getElementById("editUserForm");
 var formData = new FormData(form);
 
 if (!formData.get('username') || !formData.get('email') || !formData.get('fullName')) {
     Swal.fire("Validation Error", "Please fill all required fields", "warning");
     return;
 }
 //paswd
 var password = formData.get('password');
 if (password && password.length < 6) {
     Swal.fire("Validation Error", "Password must be at least 6 characters", "warning");
     return;
 }
 
 var isActiveCheckbox = document.querySelector('#editUserForm input[name="isActive"]');
 formData.set('isActive', isActiveCheckbox && isActiveCheckbox.checked ? 'true' : 'false');
 
 var data = new URLSearchParams(formData);
 data.append("action", "update");
 
 Swal.fire({ title: 'Updating User...', allowOutsideClick: false, didOpen: function() { Swal.showLoading(); } });

 fetch("UserServlet", {
     method: "POST",
     headers: { "Content-Type": "application/x-www-form-urlencoded" },
     body: data.toString()
 })
 .then(function(res) { return res.json(); })
 .then(function(result) {
     Swal.close();
     if (result.success) {
         Swal.fire({ icon: "success", title: "Updated!", text: result.message, timer: 2000 })
             .then(function() { location.reload(); });
     } else {
         Swal.fire("Error", result.message, "error");
     }
 })
 .catch(function(err) {
     console.error("Update Error:", err);
     Swal.close();
     Swal.fire("Error", "Failed to update user", "error");
 });
}

function deleteUser(id) {
 Swal.fire({
     title: "Delete User?",
     text: "This action cannot be undone!",
     icon: "warning",
     showCancelButton: true,
     confirmButtonColor: "#dc3545",
     confirmButtonText: "Yes, delete it!"
 }).then(function(res) {
     if (!res.isConfirmed) return;
     
     Swal.fire({ title: 'Deleting...', allowOutsideClick: false, didOpen: function() { Swal.showLoading(); } });

     fetch("UserServlet", {
         method: "POST",
         headers: { "Content-Type": "application/x-www-form-urlencoded" },
         body: "action=delete&id=" + id
     })
     .then(function(res) { return res.json(); })
     .then(function(result) {
         Swal.close();
         if (result.success) {
             Swal.fire({ icon: "success", title: "Deleted!", text: result.message, timer: 2000 })
                 .then(function() { location.reload(); });
         } else {
             Swal.fire("Error", result.message, "error");
         }
     })
     .catch(function(err) {
         console.error("Delete Error:", err);
         Swal.close();
         Swal.fire("Error", "Failed to delete user", "error");
     });
 });
}

function exportToExcel(tableType) {
 var state = tableState[tableType];
 if (!state || state.filteredRows.length === 0) {
     Swal.fire({ icon: "warning", title: "No Data", text: "Nothing to export", timer: 2000 });
     return;
 }

 var table = document.getElementById(tableType + "TableBody").closest("table");
 var headers = [];
 var headerCells = table.querySelectorAll("thead th");
 for (var i = 0; i < headerCells.length; i++) {
     var text = headerCells[i].innerText.trim();
     if (text !== "Actions" && text !== "") headers.push(text);
 }

 var csv = headers.join(",") + "\n";

 for (var j = 0; j < state.filteredRows.length; j++) {
     var cells = state.filteredRows[j].querySelectorAll("td");
     var rowData = [];
     for (var k = 0; k < cells.length - 1; k++) {
         var text = cells[k].innerText.trim().replace(/\n/g, " ").replace(/,/g, ";").replace(/"/g, '""');
         rowData.push('"' + text + '"');
     }
     csv += rowData.join(",") + "\n";
 }

 var blob = new Blob(["\uFEFF" + csv], { type: "text/csv;charset=utf-8;" });
 var link = document.createElement("a");
 link.href = URL.createObjectURL(blob);
 link.download = tableType + "_users_" + new Date().toISOString().split('T')[0] + ".csv";
 link.style.visibility = "hidden";
 document.body.appendChild(link);
 link.click();
 document.body.removeChild(link);
 
 Swal.fire({ icon: "success", title: "Exported!", text: "CSV downloaded", timer: 2000 });
}

function filterTable(tableType) {
 var state = tableState[tableType];
 var searchInput = document.getElementById(tableType + 'Search');
 var tableBody = document.getElementById(tableType + 'TableBody');
 
 state.searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
 state.statusFilter = getFilterValue(tableType, 'StatusFilter');
 state.deptFilter = getFilterValue(tableType, 'DeptFilter');
 state.classFilter = getFilterValue(tableType, 'ClassFilter');
 state.roleFilter = getFilterValue(tableType, 'RoleFilter');
 state.currentPage = 1;
 
 var allRows = tableBody.querySelectorAll('tr');
 var rows = [];
 for (var i = 0; i < allRows.length; i++) rows.push(allRows[i]);
 
 state.filteredRows = rows.filter(function(row) {
     return matchesAllFilters(row, state, tableType);
 });
 
 sortRows(tableType);
 updateTableDisplay(tableType);
}

function getFilterValue(tableType, filterName) {
 var elem = document.getElementById(tableType + filterName);
 return elem ? elem.value : 'all';
}

function matchesAllFilters(row, state, tableType) {
 var matchesSearch = !state.searchTerm || checkSearchMatch(row, state.searchTerm);
 var matchesStatus = state.statusFilter === 'all' || row.getAttribute('data-status') === state.statusFilter;
 var matchesDept = true;
 var matchesClass = true;
 var matchesRole = true;
 
 if (tableType === 'teacher' || tableType === 'student' || tableType === 'all-users') {
     var dept = row.getAttribute('data-department') || '';
     matchesDept = state.deptFilter === 'all' || dept === state.deptFilter.toLowerCase();
 }
 
 if (tableType === 'student') {
     var className = row.getAttribute('data-class') || '';
     matchesClass = state.classFilter === 'all' || className === state.classFilter.toLowerCase();
 }
 
 if (tableType === 'all-users') {
     matchesRole = state.roleFilter === 'all' || row.getAttribute('data-role') === state.roleFilter;
 }
 
 return matchesSearch && matchesStatus && matchesDept && matchesClass && matchesRole;
}

function checkSearchMatch(row, searchTerm) {
 var fields = ['name', 'username', 'email', 'phone', 'department', 'subjects', 'rollno', 'class'];
 for (var i = 0; i < fields.length; i++) {
     var value = row.getAttribute('data-' + fields[i]) || '';
     if (value.includes(searchTerm)) return true;
 }
 return false;
}

function sortTable(tableType) {
 var sortBy = document.getElementById(tableType + 'SortBy').value;
 tableState[tableType].sortBy = sortBy;
 sortRows(tableType);
 updateTableDisplay(tableType);
}

function sortRows(tableType) {
 var state = tableState[tableType];
 state.filteredRows.sort(function(a, b) {
     switch(state.sortBy) {
         case 'id': return parseInt(a.getAttribute('data-id')) - parseInt(b.getAttribute('data-id'));
         case 'name': return a.getAttribute('data-name').localeCompare(b.getAttribute('data-name'));
         case 'name_desc': return b.getAttribute('data-name').localeCompare(a.getAttribute('data-name'));
         case 'username': return a.getAttribute('data-username').localeCompare(b.getAttribute('data-username'));
         case 'email': return a.getAttribute('data-email').localeCompare(b.getAttribute('data-email'));
         case 'dept': return (a.getAttribute('data-department') || '').localeCompare(b.getAttribute('data-department') || '');
         case 'role': return a.getAttribute('data-role').localeCompare(b.getAttribute('data-role'));
         default: return 0;
     }
 });
}

function updateTableDisplay(tableType) {
 var state = tableState[tableType];
 var tableBody = document.getElementById(tableType + 'TableBody');
 var noResults = document.getElementById(tableType + 'NoResults');
 
 var allRows = tableBody.querySelectorAll('tr');
 for (var i = 0; i < allRows.length; i++) allRows[i].style.display = 'none';
 
 var startIdx = (state.currentPage - 1) * state.pageSize;
 var endIdx = Math.min(startIdx + state.pageSize, state.filteredRows.length);
 
 for (var j = startIdx; j < endIdx; j++) {
     if (state.filteredRows[j]) state.filteredRows[j].style.display = '';
 }
 
 updateCounts(tableType);
 
 if (noResults) {
     noResults.style.display = state.filteredRows.length === 0 ? 'block' : 'none';
     tableBody.style.display = state.filteredRows.length === 0 ? 'none' : '';
 }
 
 updatePagination(tableType);
}

function updateCounts(tableType) {
 var state = tableState[tableType];
 var showingCount = document.getElementById(tableType + 'ShowingCount');
 var totalCount = document.getElementById(tableType + 'TotalCount');
 if (showingCount) showingCount.textContent = state.filteredRows.length;
 if (totalCount) totalCount.textContent = state.totalRows;
}

function updatePagination(tableType) {
 var state = tableState[tableType];
 var pagination = document.getElementById(tableType + 'Pagination');
 var pageSizeSelect = document.getElementById(tableType + 'PageSize');
 
 if (pageSizeSelect) state.pageSize = parseInt(pageSizeSelect.value);
 
 var totalPages = Math.ceil(state.filteredRows.length / state.pageSize);
 state.currentPage = Math.min(state.currentPage, totalPages || 1);
 
 if (pagination && totalPages > 1) {
     var html = buildPaginationHTML(tableType, state.currentPage, totalPages);
     pagination.querySelector('ul').innerHTML = html;
     pagination.style.display = 'block';
 } else if (pagination) {
     pagination.style.display = 'none';
 }
}

function buildPaginationHTML(tableType, currentPage, totalPages) {
 var html = '<li class="page-item ' + (currentPage == 1 ? 'disabled' : '') + '">' +
     '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + (currentPage - 1) + ')">&laquo;</a></li>';
 
 var maxVisible = 5;
 var startPage = Math.max(1, currentPage - Math.floor(maxVisible / 2));
 var endPage = Math.min(totalPages, startPage + maxVisible - 1);
 
 if (endPage - startPage + 1 < maxVisible) startPage = Math.max(1, endPage - maxVisible + 1);
 
 for (var i = startPage; i <= endPage; i++) {
     html += '<li class="page-item ' + (i == currentPage ? 'active' : '') + '">' +
         '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + i + ')">' + i + '</a></li>';
 }
 
 html += '<li class="page-item ' + (currentPage == totalPages ? 'disabled' : '') + '">' +
     '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + (currentPage + 1) + ')">&raquo;</a></li>';
 
 return html;
}

function changePage(tableType, page) {
 tableState[tableType].currentPage = page;
 updateTableDisplay(tableType);
}

function clearFilters(tableType) {
 var searchInput = document.getElementById(tableType + 'Search');
 if (searchInput) searchInput.value = '';
 
 var filters = ['StatusFilter', 'DeptFilter', 'ClassFilter', 'RoleFilter', 'SortBy', 'PageSize'];
 for (var i = 0; i < filters.length; i++) {
     var elem = document.getElementById(tableType + filters[i]);
     if (elem) elem.value = (filters[i] === 'SortBy' ? 'id' : (filters[i] === 'PageSize' ? '10' : 'all'));
 }
 
 filterTable(tableType);
}

function toggleFields() {
 var role = document.getElementById('userRole').value;
 document.getElementById('studentFields').style.display = role === 'student' ? 'block' : 'none';
 document.getElementById('teacherFields').style.display = role === 'teacher' ? 'block' : 'none';
}

function toggleEditFields() {
 var role = document.getElementById('editUserRole').value;
 document.getElementById('editStudentFields').style.display = role === 'student' ? 'block' : 'none';
 document.getElementById('editTeacherFields').style.display = role === 'teacher' ? 'block' : 'none';
}

function togglePassword(fieldId) {
 var field = document.getElementById(fieldId);
 var icon = event.currentTarget.querySelector('i');
 if (field.type === 'password') {
     field.type = 'text';
     icon.classList.remove('fa-eye');
     icon.classList.add('fa-eye-slash');
 } else {
     field.type = 'password';
     icon.classList.remove('fa-eye-slash');
     icon.classList.add('fa-eye');
 }
}

function showSection(section) {
 document.getElementById('dashboard-content').style.display = 'none';
 var containers = document.querySelectorAll('.table-container');
 for (var i = 0; i < containers.length; i++) containers[i].classList.remove('active');
 
 var links = document.querySelectorAll('.nav-link');
 for (var j = 0; j < links.length; j++) {
     links[j].classList.remove('active');
     if (links[j].getAttribute('data-section') === section) links[j].classList.add('active');
 }
 
 var titles = {
     'dashboard': ['Dashboard Overview', 'Welcome back!'],
     'admin': ['Admin Management', 'Add, View, Update, Delete Administrators'],
     'teacher': ['Teacher Management', 'Add, View, Update, Delete Teachers'],
     'student': ['Student Management', 'Add, View, Update, Delete Students'],
     'all-users': ['All System Users', 'View all users in the system']
 };
 
 if (section === 'dashboard') {
     document.getElementById('dashboard-content').style.display = 'block';
 } else {
     var elem = document.getElementById(section + '-management') || document.getElementById('all-users');
     if (elem) elem.classList.add('active');
 }
 
 if (titles[section]) updatePageTitle(titles[section][0], titles[section][1]);
 
 if (window.innerWidth <= 992) {
     var sidebar = document.querySelector('.sidebar');
     if (sidebar) sidebar.classList.remove('active');
 }
}

function updatePageTitle(title, subtitle) {
 document.getElementById('page-title').textContent = title;
 document.getElementById('page-subtitle').textContent = subtitle;
}

function toggleNavSection(section) {
 var links = document.getElementById(section + '-links');
 var title = document.querySelector('[onclick="toggleNavSection(\'' + section + '\')"]');
 if (links && title) {
     links.classList.toggle('collapsed');
     var icon = title.querySelector('i');
     if (icon) icon.classList.toggle('rotated');
 }
}

function showAddUserModal(role) {
 if (typeof role === 'undefined') role = '';
 var modal = new bootstrap.Modal(document.getElementById('addUserModal'));
 document.getElementById('addUserForm').reset();
 if (role) {
     document.getElementById('userRole').value = role;
     toggleFields();
 }
 modal.show();
}

function logout() {
 Swal.fire({
     title: 'Logout?',
     text: "Are you sure?",
     icon: 'question',
     showCancelButton: true,
     confirmButtonColor: '#dc3545',
     confirmButtonText: 'Yes, logout'
 }).then(function(result) {
     if (result.isConfirmed) window.location.href = 'login?action=logout';
 });
}

function adjustNavigationForMobile() {
 var navSections = document.querySelectorAll('.nav-section');
 for (var i = 0; i < navSections.length; i++) {
     var links = navSections[i].querySelector('.nav-links');
     var icon = navSections[i].querySelector('.nav-title i');
     if (window.innerWidth <= 768) {
         if (navSections[i].querySelector('.nav-link.active')) {
             if (links) links.classList.remove('collapsed');
             if (icon) icon.classList.add('rotated');
         } else {
             if (links) links.classList.add('collapsed');
             if (icon) icon.classList.remove('rotated');
         }
     } else {
         if (links) links.classList.remove('collapsed');
         if (icon) icon.classList.add('rotated');
     }
 }
}

console.log('EduTrack Pro Admin Dashboard v1.0.0 - Ready');
</script>
</body>
</html>

