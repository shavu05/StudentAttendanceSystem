

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
    
<link rel="stylesheet" href="css/admin.css">
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
<div class="credit-badge">
    <i class="fas fa-user-graduate"></i>
    <span>Created by <strong>Shravani  </strong></span>
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
				                                 <label class="form-label">
				   								 Phone Number <span class="required-star">*</span>
												</label>

                                    <input type="tel" class="form-control" name="phone"
							       maxlength="10"
							       placeholder="Enter 10-digit mobile number"
							       oninput="restrictPhoneInput(this)">

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
                                   <label class="form-label">
   									 Phone Number <span class="required-star">*</span>
									</label>

                                    <input type="tel" class="form-control" id="editPhone" name="phone"
									       maxlength="10"
									       placeholder="Enter 10-digit mobile number"
									       oninput="restrictPhoneInput(this)">

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

<script src="js/admin.js"></script>
</body>
</html>

