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
            
            <div class="nav-section">
                <div class="nav-title" onclick="toggleNavSection('system-nav')">
                    System Management
                    <i class="fas fa-chevron-down"></i>
                </div>
                <ul class="nav-links" id="system-nav-links">
                    <li><a class="nav-link" data-section="classes" onclick="showSection('classes')">
                        <i class="fas fa-chalkboard"></i> Classes Management
                    </a></li>
                    <li><a class="nav-link" data-section="attendance" onclick="showSection('attendance')">
                        <i class="fas fa-clipboard-check"></i> Attendance Management
                    </a></li>
                    <li><a class="nav-link" data-section="reports" onclick="showSection('reports')">
                        <i class="fas fa-chart-bar"></i> Reports & Analytics
                    </a></li>
                    <li><a class="nav-link" data-section="settings" onclick="showSection('settings')">
                        <i class="fas fa-cog"></i> System Settings
                    </a></li>
                </ul>
            </div>
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
                    <small class="text-success">+5 this month</small>
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
                        <button class="btn-filter" onclick="exportToExcel('all-users')">
                            <i class="fas fa-file-excel"></i> Export
                        </button>
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

<script>
    // ========== GLOBAL VARIABLES ==========
    let currentUserId = null;
    
    // ========== INITIALIZATION ==========
    document.addEventListener('DOMContentLoaded', function() {
        // Initialize all tables
        initializeTable('admin');
        initializeTable('teacher');
        initializeTable('student');
        initializeTable('all-users');
        
        // Show dashboard by default
        showSection('dashboard');
        
        // Show success/error messages if any
        <% if (successMsg != null) { %>
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: '<%= successMsg %>',
                timer: 3000
            });
        <% } %>
        
        <% if (errorMsg != null) { %>
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: '<%= errorMsg %>',
                timer: 3000
            });
        <% } %>
        
        // Setup form submissions
        setupFormSubmissions();
        
        // Adjust navigation for mobile
        adjustNavigationForMobile();
        window.addEventListener('resize', adjustNavigationForMobile);
    });
    
    // ========== SETUP FORM SUBMISSIONS ==========
    function setupFormSubmissions() {
        // Add User Form
        document.getElementById('addUserForm').addEventListener('submit', function(e) {
            e.preventDefault();
            addUser();
        });
        
        // Edit User Form
        document.getElementById('editUserForm').addEventListener('submit', function(e) {
            e.preventDefault();
            updateUser();
        });
    }
    
    // ========== TABLE FILTERING & SEARCH FUNCTIONS ==========
    
    // Store current table state
    const tableState = {
        'admin': {
            currentPage: 1,
            pageSize: 10,
            filteredRows: [],
            totalRows: 0,
            searchTerm: '',
            statusFilter: 'all',
            sortBy: 'id'
        },
        'teacher': {
            currentPage: 1,
            pageSize: 10,
            filteredRows: [],
            totalRows: 0,
            searchTerm: '',
            statusFilter: 'all',
            deptFilter: 'all',
            sortBy: 'id'
        },
        'student': {
            currentPage: 1,
            pageSize: 10,
            filteredRows: [],
            totalRows: 0,
            searchTerm: '',
            statusFilter: 'all',
            deptFilter: 'all',
            classFilter: 'all',
            sortBy: 'id'
        },
        'all-users': {
            currentPage: 1,
            pageSize: 10,
            filteredRows: [],
            totalRows: 0,
            searchTerm: '',
            roleFilter: 'all',
            statusFilter: 'all',
            sortBy: 'id'
        }
    };
    
    function initializeTable(tableType) {
        const tableBody = document.getElementById(tableType + 'TableBody');
        if (!tableBody) return;
        
        // Get all rows
        const rows = Array.from(tableBody.querySelectorAll('tr'));
        tableState[tableType].totalRows = rows.length;
        tableState[tableType].filteredRows = rows;
        
        // Apply initial filtering
        filterTable(tableType);
    }
    
    function filterTable(tableType) {
        const state = tableState[tableType];
        const searchInput = document.getElementById(tableType + 'Search');
        const statusFilter = document.getElementById(tableType + 'StatusFilter');
        const deptFilter = document.getElementById(tableType + 'DeptFilter');
        const classFilter = document.getElementById(tableType + 'ClassFilter');
        const roleFilter = document.getElementById(tableType + 'RoleFilter');
        const tableBody = document.getElementById(tableType + 'TableBody');
        const noResults = document.getElementById(tableType + 'NoResults');
        const showingCount = document.getElementById(tableType + 'ShowingCount');
        const totalCount = document.getElementById(tableType + 'TotalCount');
        
        // Update state
        state.searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
        state.statusFilter = statusFilter ? statusFilter.value : 'all';
        state.deptFilter = deptFilter ? deptFilter.value : 'all';
        state.classFilter = classFilter ? classFilter.value : 'all';
        state.roleFilter = roleFilter ? roleFilter.value : 'all';
        state.currentPage = 1;
        
        // Get all rows
        const rows = Array.from(tableBody.querySelectorAll('tr'));
        
        // Filter rows
        state.filteredRows = rows.filter(row => {
            // Search filter
            const searchFields = ['name', 'username', 'email', 'phone', 'department', 'subjects', 'rollno', 'class'];
            let matchesSearch = false;
            
            if (!state.searchTerm) {
                matchesSearch = true;
            } else {
                for (const field of searchFields) {
                    const value = row.getAttribute('data-' + field) || '';
                    if (value.includes(state.searchTerm)) {
                        matchesSearch = true;
                        break;
                    }
                }
            }
            
            // Status filter
            const status = row.getAttribute('data-status');
            let matchesStatus = state.statusFilter === 'all' || status === state.statusFilter;
            
            // Department filter
            let matchesDept = true;
            if (tableType === 'teacher' || tableType === 'student' || tableType === 'all-users') {
                const dept = row.getAttribute('data-department') || '';
                matchesDept = state.deptFilter === 'all' || dept === state.deptFilter.toLowerCase();
            }
            
            // Class filter
            let matchesClass = true;
            if (tableType === 'student') {
                const className = row.getAttribute('data-class') || '';
                matchesClass = state.classFilter === 'all' || className === state.classFilter.toLowerCase();
            }
            
            // Role filter
            let matchesRole = true;
            if (tableType === 'all-users') {
                const role = row.getAttribute('data-role');
                matchesRole = state.roleFilter === 'all' || role === state.roleFilter;
            }
            
            return matchesSearch && matchesStatus && matchesDept && matchesClass && matchesRole;
        });
        
        // Sort rows
        sortRows(tableType);
        
        // Update display
        updateTableDisplay(tableType);
    }
    
    function sortTable(tableType) {
        const sortBy = document.getElementById(tableType + 'SortBy').value;
        tableState[tableType].sortBy = sortBy;
        sortRows(tableType);
        updateTableDisplay(tableType);
    }
    
    function sortRows(tableType) {
        const state = tableState[tableType];
        
        state.filteredRows.sort((a, b) => {
            switch(state.sortBy) {
                case 'id':
                    return parseInt(a.getAttribute('data-id')) - parseInt(b.getAttribute('data-id'));
                case 'name':
                    return a.getAttribute('data-name').localeCompare(b.getAttribute('data-name'));
                case 'name_desc':
                    return b.getAttribute('data-name').localeCompare(a.getAttribute('data-name'));
                case 'username':
                    return a.getAttribute('data-username').localeCompare(b.getAttribute('data-username'));
                case 'email':
                    return a.getAttribute('data-email').localeCompare(b.getAttribute('data-email'));
                case 'dept':
                    return (a.getAttribute('data-department') || '').localeCompare(b.getAttribute('data-department') || '');
                case 'role':
                    return a.getAttribute('data-role').localeCompare(b.getAttribute('data-role'));
                default:
                    return 0;
            }
        });
    }
    
    function updateTableDisplay(tableType) {
        const state = tableState[tableType];
        const tableBody = document.getElementById(tableType + 'TableBody');
        const noResults = document.getElementById(tableType + 'NoResults');
        const showingCount = document.getElementById(tableType + 'ShowingCount');
        const totalCount = document.getElementById(tableType + 'TotalCount');
        const pagination = document.getElementById(tableType + 'Pagination');
        
        // Hide all rows first
        const allRows = tableBody.querySelectorAll('tr');
        allRows.forEach(row => row.style.display = 'none');
        
        // Calculate pagination
        const totalPages = Math.ceil(state.filteredRows.length / state.pageSize);
        const startIndex = (state.currentPage - 1) * state.pageSize;
        const endIndex = Math.min(startIndex + state.pageSize, state.filteredRows.length);
        
        // Show rows for current page
        for (let i = startIndex; i < endIndex; i++) {
            if (state.filteredRows[i]) {
                state.filteredRows[i].style.display = '';
            }
        }
        
        // Update counts
        if (showingCount) showingCount.textContent = state.filteredRows.length;
        if (totalCount) totalCount.textContent = state.totalRows;
        
        // Show/hide no results message
        if (noResults) {
            if (state.filteredRows.length === 0) {
                noResults.style.display = 'block';
                tableBody.style.display = 'none';
            } else {
                noResults.style.display = 'none';
                tableBody.style.display = '';
            }
        }
        
        // Update pagination
        updatePagination(tableType);
    }
    
    function updatePagination(tableType) {
        const state = tableState[tableType];
        const pageSizeSelect = document.getElementById(tableType + 'PageSize');
        const pagination = document.getElementById(tableType + 'Pagination');
        
        if (pageSizeSelect) {
            state.pageSize = parseInt(pageSizeSelect.value);
        }
        
        const totalPages = Math.ceil(state.filteredRows.length / state.pageSize);
        state.currentPage = Math.min(state.currentPage, totalPages || 1);
        
        if (pagination && totalPages > 1) {
            let paginationHTML = '';
            
            // Previous button
            paginationHTML += '<li class="page-item ' + (state.currentPage == 1 ? 'disabled' : '') + '">';
            paginationHTML += '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + (state.currentPage - 1) + ')">&laquo;</a>';
            paginationHTML += '</li>';
            
            // Page numbers
            const maxVisiblePages = 5;
            let startPage = Math.max(1, state.currentPage - Math.floor(maxVisiblePages / 2));
            let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
            
            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }
            
            for (let i = startPage; i <= endPage; i++) {
                paginationHTML += '<li class="page-item ' + (i == state.currentPage ? 'active' : '') + '">';
                paginationHTML += '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + i + ')">' + i + '</a>';
                paginationHTML += '</li>';
            }
            
            // Next button
            paginationHTML += '<li class="page-item ' + (state.currentPage == totalPages ? 'disabled' : '') + '">';
            paginationHTML += '<a class="page-link" href="#" onclick="changePage(\'' + tableType + '\', ' + (state.currentPage + 1) + ')">&raquo;</a>';
            paginationHTML += '</li>';
            
            pagination.querySelector('ul').innerHTML = paginationHTML;
            pagination.style.display = 'block';
        } else if (pagination) {
            pagination.style.display = 'none';
        }
        
        updateTableDisplay(tableType);
    }
    
    function changePage(tableType, page) {
        const state = tableState[tableType];
        state.currentPage = page;
        updateTableDisplay(tableType);
    }
    
    function clearFilters(tableType) {
        // Reset search input
        const searchInput = document.getElementById(tableType + 'Search');
        if (searchInput) searchInput.value = '';
        
        // Reset filters
        const filters = ['StatusFilter', 'DeptFilter', 'ClassFilter', 'RoleFilter', 'SortBy'];
        filters.forEach(filter => {
            const element = document.getElementById(tableType + filter);
            if (element) {
                if (filter === 'SortBy') {
                    element.value = 'id';
                } else {
                    element.value = 'all';
                }
            }
        });
        
        // Reset page size
        const pageSize = document.getElementById(tableType + 'PageSize');
        if (pageSize) pageSize.value = '10';
        
        // Reapply filters
        filterTable(tableType);
    }
    
    // ========== EXPORT FUNCTIONS (FIXED) ==========
// ========== EXPORT FUNCTIONS (FIXED FOR ALL TABLES) ==========
function exportToExcel(tableType) {
    const tableId = tableType + 'TableBody';
    const table = document.getElementById(tableId);
    
    if (!table) {
        Swal.fire({
            icon: 'warning',
            title: 'No Table',
            text: 'Table not found.',
            timer: 2000
        });
        return;
    }
    
    // Get all visible rows (not filtered by pagination)
    const allRows = table.querySelectorAll('tr');
    const visibleRows = Array.from(allRows).filter(row => row.style.display !== 'none');
    
    if (visibleRows.length === 0) {
        // If no visible rows, try to get all rows from tableState
        const rows = tableState[tableType] ? tableState[tableType].filteredRows : [];
        if (rows.length === 0) {
            Swal.fire({
                icon: 'warning',
                title: 'No Data',
                text: 'There is no data to export.',
                timer: 2000
            });
            return;
        }
        exportFilteredRows(tableType, rows);
        return;
    }
    
    exportVisibleRows(tableType, visibleRows);
}

function exportVisibleRows(tableType, visibleRows) {
    // Get table headers (excluding Actions column)
    const table = document.getElementById(tableType + 'TableBody').closest('table');
    const headers = Array.from(table.querySelectorAll('thead th')).map(th => {
        return th.textContent.trim();
    }).filter(header => header !== 'Actions' && header !== '');
    
    let csvContent = '';
    
    // Add headers
    csvContent += headers.join(',') + '\n';
    
    // Add data rows
    visibleRows.forEach(row => {
        const cells = Array.from(row.querySelectorAll('td'));
        const rowData = [];
        
        // Process each cell (skip actions column)
        for (let i = 0; i < cells.length - 1; i++) {
            const cell = cells[i];
            let cellText = cell.textContent.trim();
            
            // Clean up badge text
            const badges = cell.querySelectorAll('.badge');
            if (badges.length > 0) {
                cellText = Array.from(badges).map(badge => badge.textContent.trim()).join(', ');
            }
            
            // Handle commas and quotes in CSV
            if (cellText.includes(',') || cellText.includes('"') || cellText.includes('\n')) {
                cellText = '"' + cellText.replace(/"/g, '""') + '"';
            }
            
            rowData.push(cellText);
        }
        
        csvContent += rowData.join(',') + '\n';
    });
    
    downloadCSV(csvContent, tableType);
}

function exportFilteredRows(tableType, rows) {
    // Get table headers (excluding Actions column)
    const table = document.getElementById(tableType + 'TableBody').closest('table');
    const headers = Array.from(table.querySelectorAll('thead th')).map(th => {
        return th.textContent.trim();
    }).filter(header => header !== 'Actions' && header !== '');
    
    let csvContent = '';
    
    // Add headers
    csvContent += headers.join(',') + '\n';
    
    // Add data rows
    rows.forEach(row => {
        const cells = Array.from(row.querySelectorAll('td'));
        const rowData = [];
        
        // Process each cell (skip actions column)
        for (let i = 0; i < cells.length - 1; i++) {
            const cell = cells[i];
            let cellText = cell.textContent.trim();
            
            // Clean up badge text
            const badges = cell.querySelectorAll('.badge');
            if (badges.length > 0) {
                cellText = Array.from(badges).map(badge => badge.textContent.trim()).join(', ');
            }
            
            // Handle commas and quotes in CSV
            if (cellText.includes(',') || cellText.includes('"') || cellText.includes('\n')) {
                cellText = '"' + cellText.replace(/"/g, '""') + '"';
            }
            
            rowData.push(cellText);
        }
        
        csvContent += rowData.join(',') + '\n';
    });
    
    downloadCSV(csvContent, tableType);
}

function downloadCSV(csvContent, tableType) {
    // Create and download CSV file
    const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    const filename = tableType + '_users_' + new Date().toISOString().slice(0, 10) + '.csv';
    
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // Clean up
    setTimeout(() => URL.revokeObjectURL(url), 100);
    
    Swal.fire({
        icon: 'success',
        title: 'Exported!',
        text: 'Data exported successfully to ' + filename,
        timer: 2000
    });
}

    // ========== SECTION NAVIGATION ==========
    function showSection(section) {
        // Hide all sections first
        document.getElementById('dashboard-content').style.display = 'none';
        document.querySelectorAll('.table-container').forEach(container => {
            container.classList.remove('active');
        });
        
        // Update active nav link
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('data-section') === section) {
                link.classList.add('active');
            }
        });
        
        // Show selected section
        if (section === 'dashboard') {
            document.getElementById('dashboard-content').style.display = 'block';
            updatePageTitle('Dashboard Overview', 'Welcome back, ' + '<%= user.getFullName() %>');
        } else if (section === 'admin') {
            document.getElementById('admin-management').classList.add('active');
            updatePageTitle('Admin Management', 'Add, View, Update, Delete Administrators');
        } else if (section === 'teacher') {
            document.getElementById('teacher-management').classList.add('active');
            updatePageTitle('Teacher Management', 'Add, View, Update, Delete Teachers');
        } else if (section === 'student') {
            document.getElementById('student-management').classList.add('active');
            updatePageTitle('Student Management', 'Add, View, Update, Delete Students');
        } else if (section === 'all-users') {
            document.getElementById('all-users').classList.add('active');
            updatePageTitle('All System Users', 'View all users in the system');
        } else {
            updatePageTitle(section.charAt(0).toUpperCase() + section.slice(1) + ' Management', 
                'Manage ' + section + ' details');
        }
        
        // Close sidebar on mobile after clicking
        if (window.innerWidth <= 992) {
            document.querySelector('.sidebar').classList.remove('active');
        }
    }
    
    function updatePageTitle(title, subtitle) {
        document.getElementById('page-title').textContent = title;
        document.getElementById('page-subtitle').textContent = subtitle;
    }
    
    // ========== COLLAPSIBLE NAVIGATION SECTIONS ==========
    function toggleNavSection(section) {
        const links = document.getElementById(section + '-links');
        const title = document.querySelector('[onclick="toggleNavSection(\'' + section + '\')"]');
        const icon = title.querySelector('i');
        
        links.classList.toggle('collapsed');
        icon.classList.toggle('rotated');
    }
    
    // ========== MOBILE MENU TOGGLE ==========
    document.getElementById('menuToggle').addEventListener('click', function() {
        document.querySelector('.sidebar').classList.toggle('active');
    });
    
    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function(event) {
        const sidebar = document.querySelector('.sidebar');
        const menuToggle = document.getElementById('menuToggle');
        
        if (window.innerWidth <= 992 && 
            sidebar.classList.contains('active') && 
            !sidebar.contains(event.target) && 
            event.target !== menuToggle && 
            !menuToggle.contains(event.target)) {
            sidebar.classList.remove('active');
        }
    });
    
    // ========== CRUD OPERATIONS ==========
    
    // CREATE - Add New User (COMPLETELY FIXED)
function addUser() {
    const form = document.getElementById('addUserForm');
    const formData = new FormData(form);
    const addUserBtn = document.getElementById('addUserBtn');
    
    console.log("=== DEBUG: Add User Process Starting ===");
    
    // Get ALL form fields explicitly
    const userRole = document.getElementById('userRole').value;
    const fullName = document.querySelector('input[name="fullName"]').value;
    const username = document.querySelector('input[name="username"]').value;
    const password = document.getElementById('passwordField').value;
    const email = document.querySelector('input[name="email"]').value;
    const phone = document.querySelector('input[name="phone"]').value || '';
    const department = document.querySelector('select[name="department"]').value || '';
    const subjects = document.querySelector('input[name="subjects"]')?.value || '';
    const rollNo = document.querySelector('input[name="rollNo"]')?.value || '';
    const className = document.querySelector('select[name="className"]')?.value || '';
    const isActive = document.querySelector('input[name="isActive"]').checked;
    
    console.log("Form Data Collected:");
    console.log("- Role:", userRole);
    console.log("- Full Name:", fullName);
    console.log("- Username:", username);
    console.log("- Password:", password ? "[HIDDEN]" : "EMPTY");
    console.log("- Email:", email);
    console.log("- Phone:", phone);
    console.log("- Department:", department);
    console.log("- Subjects:", subjects);
    console.log("- Roll No:", rollNo);
    console.log("- Class:", className);
    console.log("- Active:", isActive);
    
    // Create URL encoded data instead of FormData (more reliable)
    const params = new URLSearchParams();
    params.append('action', 'add');
    params.append('role', userRole);
    params.append('fullName', fullName);
    params.append('username', username);
    params.append('password', password);
    params.append('email', email);
    if (phone) params.append('phone', phone);
    if (department) params.append('department', department);
    if (subjects) params.append('subjects', subjects);
    if (rollNo) params.append('rollNo', rollNo);
    if (className) params.append('className', className);
    params.append('isActive', isActive ? 'true' : 'false');
    
    console.log("Final Parameters:", params.toString());
    
    // Disable button and show loading state
    addUserBtn.disabled = true;
    addUserBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Adding...';
    
    fetch('UserServlet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString()
    })
    .then(response => {
        console.log("Response received, status:", response.status);
        return response.json();
    })
    .then(result => {
        console.log("Server Response:", result);
        
        if (result.success) {
            // Show SUCCESS message with SweetAlert
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: result.message,
                showConfirmButton: true,
                confirmButtonText: 'OK',
                timer: 3000
            }).then((result) => {
                if (result.isConfirmed || result.isDismissed) {
                    // Close modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('addUserModal'));
                    if (modal) {
                        modal.hide();
                    }
                    
                    // Reset form
                    form.reset();
                    
                    // Reload page to show new user
                    setTimeout(() => {
                        window.location.reload();
                    }, 500);
                }
            });
        } else {
            // Show ERROR message
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: result.message || 'Failed to add user',
                showConfirmButton: true,
                confirmButtonText: 'OK'
            });
        }
    })
    .catch(error => {
        console.error('Fetch Error:', error);
        Swal.fire({
            icon: 'error',
            title: 'Network Error!',
            text: 'Failed to connect to server. Please check console for details.',
            showConfirmButton: true,
            confirmButtonText: 'OK'
        });
    })
    .finally(() => {
        // Reset button state
        addUserBtn.disabled = false;
        addUserBtn.innerHTML = '<i class="fas fa-user-plus me-2"></i> Add User';
    });
    
    // Prevent default form submission
    return false;
}
    
    
    // READ - View User Details
    function viewUser(userId) {
        currentUserId = userId;
        
        // Show loading
        document.getElementById('viewUserLoading').style.display = 'block';
        document.getElementById('userDetailsContent').style.display = 'none';
        
        // Fetch user details
        fetch('UserServlet?action=getUser&id=' + userId)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(user => {
                console.log('User data received:', user);
                
                // Check if we got an error response
                if (user && user.success === false) {
                    throw new Error(user.message || 'Failed to load user');
                }
                
                if (!user || !user.id) {
                    throw new Error('Invalid user data received');
                }
                
                // Format user details
                let userDetails = '';
                userDetails += '<div class="row">';
                userDetails += '<div class="col-md-4 text-center">';
                userDetails += '<div class="user-avatar-large">';
                userDetails += user.fullName ? user.fullName.charAt(0).toUpperCase() : '?';
                userDetails += '</div>';
                userDetails += '<h4 class="mt-3">' + (user.fullName || 'Unknown') + '</h4>';
                userDetails += user.active ? 
                    '<span class="badge bg-success status-badge">Active</span>' : 
                    '<span class="badge bg-danger status-badge">Inactive</span>';
                userDetails += '<p class="text-muted mt-2">' + (user.role ? user.role.toUpperCase() : 'USER') + '</p>';
                userDetails += '</div>';
                userDetails += '<div class="col-md-8">';
                userDetails += '<div class="detail-row">';
                userDetails += '<div class="detail-label">Username:</div>';
                userDetails += '<div class="detail-value">' + (user.username || 'N/A') + '</div>';
                userDetails += '</div>';
                userDetails += '<div class="detail-row">';
                userDetails += '<div class="detail-label">Email:</div>';
                userDetails += '<div class="detail-value">' + (user.email || 'N/A') + '</div>';
                userDetails += '</div>';
                userDetails += '<div class="detail-row">';
                userDetails += '<div class="detail-label">Phone:</div>';
                userDetails += '<div class="detail-value">' + (user.phone || 'N/A') + '</div>';
                userDetails += '</div>';
                
                if (user.department) {
                    userDetails += '<div class="detail-row">';
                    userDetails += '<div class="detail-label">Department:</div>';
                    userDetails += '<div class="detail-value">' + user.department + '</div>';
                    userDetails += '</div>';
                }
                
                // Student specific fields
                if (user.role === 'student') {
                    if (user.rollNo) {
                        userDetails += '<div class="detail-row">';
                        userDetails += '<div class="detail-label">Roll Number:</div>';
                        userDetails += '<div class="detail-value">' + user.rollNo + '</div>';
                        userDetails += '</div>';
                    }
                    if (user.className) {
                        userDetails += '<div class="detail-row">';
                        userDetails += '<div class="detail-label">Class:</div>';
                        userDetails += '<div class="detail-value">' + user.className + '</div>';
                        userDetails += '</div>';
                    }
                }
                
                // Teacher specific fields
                if (user.role === 'teacher' && user.subjects) {
                    userDetails += '<div class="detail-row">';
                    userDetails += '<div class="detail-label">Subjects:</div>';
                    userDetails += '<div class="detail-value">' + user.subjects + '</div>';
                    userDetails += '</div>';
                }
                
                userDetails += '<div class="detail-row">';
                userDetails += '<div class="detail-label">User ID:</div>';
                userDetails += '<div class="detail-value">' + user.id + '</div>';
                userDetails += '</div>';
                
                if (user.createdAt) {
                    userDetails += '<div class="detail-row">';
                    userDetails += '<div class="detail-label">Account Created:</div>';
                    userDetails += '<div class="detail-value">' + new Date(user.createdAt).toLocaleDateString() + '</div>';
                    userDetails += '</div>';
                }
                
                userDetails += '</div>';
                userDetails += '</div>';
                
                // Update modal content
                document.getElementById('userDetailsContent').innerHTML = userDetails;
                
                // Hide loading, show content
                document.getElementById('viewUserLoading').style.display = 'none';
                document.getElementById('userDetailsContent').style.display = 'block';
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('viewUserModal'));
                modal.show();
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('viewUserLoading').style.display = 'none';
                
                // Show error in modal
                document.getElementById('userDetailsContent').innerHTML = 
                    '<div class="alert alert-danger text-center">' + error.message + '</div>';
                document.getElementById('userDetailsContent').style.display = 'block';
                
                const modal = new bootstrap.Modal(document.getElementById('viewUserModal'));
                modal.show();
            });
    }
    
    // UPDATE - Edit User
    function editUser(userId) {
        currentUserId = userId;
        
        console.log('Editing user ID:', userId);
        
        // Fetch user data
        fetch('UserServlet?action=getUser&id=' + userId)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.json();
            })
            .then(user => {
                console.log('Edit user data received:', user);
                
                if (!user || user.success === false) {
                    throw new Error(user ? user.message : 'User not found');
                }
                
                // Populate form fields
                document.getElementById('editUserId').value = user.id;
                document.getElementById('editUserRole').value = user.role || '';
                document.getElementById('editFullName').value = user.fullName || '';
                document.getElementById('editUsername').value = user.username || '';
                document.getElementById('editEmail').value = user.email || '';
                document.getElementById('editPhone').value = user.phone || '';
                document.getElementById('editDepartment').value = user.department || '';
                document.getElementById('editSubjects').value = user.subjects || '';
                document.getElementById('editRollNo').value = user.rollNo || '';
                document.getElementById('editClassName').value = user.className || '';
                document.getElementById('editIsActive').checked = user.active || true;
                document.getElementById('statusText').textContent = user.active ? 'Active' : 'Inactive';
                
                // Clear password field
                document.getElementById('editPassword').value = '';
                
                // Toggle role-specific fields
                toggleEditFields();
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('editUserModal'));
                modal.show();
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Failed to load user data: ' + error.message
                });
            });
    }
    
    // Update User
    function updateUser() {
        const form = document.getElementById('editUserForm');
        const formData = new FormData(form);
        const updateUserBtn = document.getElementById('updateUserBtn');
        
        // Get isActive checkbox value
        const isActiveCheckbox = document.querySelector('#editUserForm input[name="isActive"]');
        formData.set('isActive', isActiveCheckbox.checked ? 'true' : 'false');
        
        // Add action parameter
        formData.set('action', 'update');
        
        // Disable button and show loading
        updateUserBtn.disabled = true;
        updateUserBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Updating...';
        
        fetch('UserServlet', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.status);
            }
            return response.json();
        })
        .then(result => {
            console.log('Update user response:', result);
            
            if (result.success) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: result.message,
                    showConfirmButton: false,
                    timer: 2000
                }).then(() => {
                    // Close modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('editUserModal'));
                    if (modal) modal.hide();
                    
                    // Reload page
                    window.location.reload();
                });
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: result.message || 'Failed to update user'
                });
            }
        })
        .catch(error => {
            console.error('Error:', error);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Failed to update user: ' + error.message
            });
        })
        .finally(() => {
            // Reset button state
            updateUserBtn.disabled = false;
            updateUserBtn.innerHTML = '<i class="fas fa-save me-2"></i> Update User';
        });
    }
    
    // DELETE - Remove User
    function deleteUser(userId) {
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                // Send delete request
                const formData = new FormData();
                formData.append('action', 'delete');
                formData.append('id', userId);
                
                fetch('UserServlet', {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(result => {
                    if (result.success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Deleted!',
                            text: result.message,
                            showConfirmButton: false,
                            timer: 2000
                        }).then(() => {
                            // Remove row from table
                            const row = document.querySelector('tr[data-id="' + userId + '"]');
                            if (row) {
                                row.remove();
                                updateUserStats();
                            } else {
                                window.location.reload();
                            }
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: result.message
                        });
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to delete user.'
                    });
                });
            }
        });
    }
    
    // ========== HELPER FUNCTIONS ==========
    
    function toggleFields() {
        const role = document.getElementById('userRole').value;
        const studentFields = document.getElementById('studentFields');
        const teacherFields = document.getElementById('teacherFields');
        
        studentFields.style.display = 'none';
        teacherFields.style.display = 'none';
        
        if (role === 'student') {
            studentFields.style.display = 'block';
        } else if (role === 'teacher') {
            teacherFields.style.display = 'block';
        }
    }
    
    function toggleEditFields() {
        const role = document.getElementById('editUserRole').value;
        const studentFields = document.getElementById('editStudentFields');
        const teacherFields = document.getElementById('editTeacherFields');
        
        studentFields.style.display = 'none';
        teacherFields.style.display = 'none';
        
        if (role === 'student') {
            studentFields.style.display = 'block';
        } else if (role === 'teacher') {
            teacherFields.style.display = 'block';
        }
    }
    
    function togglePassword(fieldId) {
        const field = document.getElementById(fieldId);
        const toggleBtn = event.currentTarget;
        const icon = toggleBtn.querySelector('i');
        
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
    
    function editUserFromView() {
        // Close view modal
        const viewModal = bootstrap.Modal.getInstance(document.getElementById('viewUserModal'));
        if (viewModal) viewModal.hide();
        
        // Open edit modal
        setTimeout(() => {
            editUser(currentUserId);
        }, 300);
    }
    
    function updateUserStats() {
        fetch('UserServlet?action=getStats')
            .then(response => response.json())
            .then(stats => {
                // Update the stats cards
                const statValues = document.querySelectorAll('.stat-value');
                if (statValues.length >= 4) {
                    statValues[0].textContent = stats.totalUsers || 0;
                    statValues[1].textContent = stats.totalAdmins || 0;
                    statValues[2].textContent = stats.totalTeachers || 0;
                    statValues[3].textContent = stats.totalStudents || 0;
                }
            })
            .catch(error => console.error('Error updating stats:', error));
    }
    
    function logout() {
        if (confirm('Are you sure you want to logout?')) {
            window.location.href = 'login?action=logout';
        }
    }
    
    function showAddUserModal(role = '') {
        const modal = new bootstrap.Modal(document.getElementById('addUserModal'));
        
        // Reset form
        document.getElementById('addUserForm').reset();
        
        // Set role if provided
        if (role) {
            document.getElementById('userRole').value = role;
            toggleFields();
        }
        
        modal.show();
    }
    
    // ========== STATUS CHANGE HANDLER ==========
    document.getElementById('editIsActive').addEventListener('change', function() {
        document.getElementById('statusText').textContent = this.checked ? 'Active' : 'Inactive';
    });
    
    function adjustNavigationForMobile() {
        const navSections = document.querySelectorAll('.nav-section');
        
        if (window.innerWidth <= 768) {
            navSections.forEach(section => {
                const links = section.querySelector('.nav-links');
                const icon = section.querySelector('.nav-title i');
                
                if (section.querySelector('.nav-link.active')) {
                    links.classList.remove('collapsed');
                    icon.classList.add('rotated');
                } else {
                    links.classList.add('collapsed');
                    icon.classList.remove('rotated');
                }
            });
        } else {
            navSections.forEach(section => {
                const links = section.querySelector('.nav-links');
                const icon = section.querySelector('.nav-title i');
                
                links.classList.remove('collapsed');
                icon.classList.add('rotated');
            });
        }
    }
</script>
</body>
</html>
