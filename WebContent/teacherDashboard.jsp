<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="com.attendance.util.DatabaseConnection" %>
<%
    // Session check
    if (session.getAttribute("user") == null || !"teacher".equals(session.getAttribute("role"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String teacherName = (String) session.getAttribute("fullName");
    Integer teacherId = (Integer) session.getAttribute("userId");
    
    // Get today's date
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String today = sdf.format(Calendar.getInstance().getTime());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard - Attendance System</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        :root {
            --primary-color: #4361ee;
            --secondary-color: #3a0ca3;
            --success-color: #06d6a0;
            --danger-color: #ef476f;
            --warning-color: #ffd166;
        }
        
        body {
            background: #f5f7fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .sidebar {
            background: linear-gradient(180deg, var(--primary-color), var(--secondary-color));
            min-height: 100vh;
            color: white;
            position: fixed;
            width: 260px;
            top: 0;
            left: 0;
            z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        
        .sidebar .logo {
            padding: 25px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .sidebar .nav-link {
            color: rgba(255,255,255,0.85);
            padding: 12px 20px;
            margin: 5px 10px;
            border-radius: 8px;
            transition: all 0.3s;
        }
        
        .sidebar .nav-link:hover,
        .sidebar .nav-link.active {
            background: rgba(255,255,255,0.15);
            color: white;
        }
        
        .sidebar .nav-link i {
            width: 25px;
            margin-right: 10px;
        }
        
        .main-content {
            margin-left: 260px;
            padding: 20px;
        }
        
        .header-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            text-align: center;
            transition: transform 0.3s;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card i {
            font-size: 40px;
            margin-bottom: 15px;
        }
        
        .stat-card .stat-value {
            font-size: 32px;
            font-weight: 700;
            margin: 10px 0;
        }
        
        .stat-card .stat-label {
            color: #6c757d;
            font-size: 14px;
            text-transform: uppercase;
        }
        
        .card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }
        
        .card-header {
            background: white;
            border-bottom: 1px solid #e9ecef;
            padding: 20px;
            font-weight: 600;
        }
        
        .btn-present {
            background: var(--success-color);
            color: white;
            border: none;
        }
        
        .btn-present:hover {
            background: #05c494;
            color: white;
        }
        
        .btn-absent {
            background: var(--danger-color);
            color: white;
            border: none;
        }
        
        .btn-absent:hover {
            background: #d93d5f;
            color: white;
        }
        
        .attendance-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .badge-present {
            background: rgba(6, 214, 160, 0.2);
            color: var(--success-color);
        }
        
        .badge-absent {
            background: rgba(239, 71, 111, 0.2);
            color: var(--danger-color);
        }
        
        .table th {
            background: #f8f9fa;
            font-weight: 600;
            border-bottom: 2px solid #dee2e6;
        }
        
        .loading {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255,255,255,0.9);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }
        
        .spinner {
            width: 60px;
            height: 60px;
            border: 5px solid #f3f3f3;
            border-top: 5px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .page-section {
            display: none;
        }
        
        .page-section.active {
            display: block;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                margin-left: -260px;
            }
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
    <!-- Loading Spinner -->
    <div class="loading" id="loading">
        <div class="spinner"></div>
    </div>

    <!-- Sidebar -->
    <div class="sidebar">
        <div class="logo">
            <h4><i class="fas fa-chalkboard-teacher"></i> Teacher Portal</h4>
            <small>Welcome, <%= teacherName %></small>
        </div>
        
        <nav class="nav flex-column mt-4">
            <a class="nav-link active" href="#" onclick="showPage('dashboard')">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a class="nav-link" href="#" onclick="showPage('mark-attendance')">
                <i class="fas fa-calendar-check"></i> Mark Attendance
            </a>
            <a class="nav-link" href="#" onclick="showPage('view-attendance')">
                <i class="fas fa-list"></i> View Attendance
            </a>
            <a class="nav-link" href="#" onclick="showPage('reports')">
                <i class="fas fa-chart-bar"></i> Reports
            </a>
            <a class="nav-link" href="#" onclick="showPage('students')">
                <i class="fas fa-users"></i> Students
            </a>
            <div class="mt-auto p-3">
                <a class="nav-link text-danger" href="LoginServlet?action=logout">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </nav>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        
        <!-- Dashboard Section -->
        <div id="dashboard" class="page-section active">
            <div class="header-card">
                <h2>Teacher Dashboard</h2>
                <p class="text-muted mb-0">Manage student attendance and view reports</p>
            </div>

            <!-- Statistics -->
            <div class="row mb-4">
                <%
                    Connection conn = null;
                    PreparedStatement pst = null;
                    ResultSet rs = null;
                    
                    int totalStudents = 0;
                    int todayPresent = 0;
                    int todayAbsent = 0;
                    double avgAttendance = 0.0;
                    
                    try {
                        conn = DatabaseConnection.getConnection();
                        
                        // Total students
                        String sql1 = "SELECT COUNT(*) as total FROM users WHERE role='student' AND is_active=1";
                        pst = conn.prepareStatement(sql1);
                        rs = pst.executeQuery();
                        if (rs.next()) totalStudents = rs.getInt("total");
                        rs.close();
                        pst.close();
                        
                        // Today's present
                        String sql2 = "SELECT COUNT(*) as present FROM attendance WHERE attendance_date=CURDATE() AND status='present'";
                        pst = conn.prepareStatement(sql2);
                        rs = pst.executeQuery();
                        if (rs.next()) todayPresent = rs.getInt("present");
                        rs.close();
                        pst.close();
                        
                        // Today's absent
                        String sql3 = "SELECT COUNT(*) as absent FROM attendance WHERE attendance_date=CURDATE() AND status='absent'";
                        pst = conn.prepareStatement(sql3);
                        rs = pst.executeQuery();
                        if (rs.next()) todayAbsent = rs.getInt("absent");
                        rs.close();
                        pst.close();
                        
                        // Average attendance
                        if (totalStudents > 0) {
                            avgAttendance = (double) todayPresent / totalStudents * 100;
                        }
                        
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
                
                <div class="col-md-3">
                    <div class="stat-card">
                        <i class="fas fa-users text-primary"></i>
                        <div class="stat-value"><%= totalStudents %></div>
                        <div class="stat-label">Total Students</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <i class="fas fa-user-check text-success"></i>
                        <div class="stat-value"><%= todayPresent %></div>
                        <div class="stat-label">Today Present</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <i class="fas fa-user-times text-danger"></i>
                        <div class="stat-value"><%= todayAbsent %></div>
                        <div class="stat-label">Today Absent</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <i class="fas fa-percentage text-warning"></i>
                        <div class="stat-value"><%= String.format("%.1f", avgAttendance) %>%</div>
                        <div class="stat-label">Attendance Rate</div>
                    </div>
                </div>
            </div>

            <!-- Chart -->
            <div class="row">
                <div class="col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">Last 7 Days Attendance</h5>
                        </div>
                        <div class="card-body">
                            <canvas id="attendanceChart" height="80"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mark Attendance Section -->
        <div id="mark-attendance" class="page-section">
            <div class="header-card">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h2>Mark Attendance</h2>
                        <p class="text-muted mb-0">Mark students present or absent</p>
                    </div>
                    <div class="col-md-6 text-end">
                        <button class="btn btn-success" onclick="markAllPresent()">
                            <i class="fas fa-check-circle"></i> Mark All Present
                        </button>
                        <button class="btn btn-primary" onclick="saveAllAttendance()">
                            <i class="fas fa-save"></i> Save Attendance
                        </button>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-md-4">
                            <label>Date:</label>
                            <input type="date" class="form-control" id="attendanceDate" 
                                   value="<%= today %>" onchange="loadAttendanceForDate()">
                        </div>
                        <div class="col-md-4">
                            <label>Class Filter:</label>
                            <select class="form-select" id="classFilter" onchange="loadAttendanceForDate()">
                                <option value="">All Classes</option>
                                <option value="10A">10A</option>
                                <option value="10-A">10-A</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label>&nbsp;</label>
                            <div>
                                <span class="badge bg-primary">Selected Date: <span id="selectedDateDisplay"><%= today %></span></span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover" id="attendanceTable">
                            <thead>
                                <tr>
                                    <th>Roll No</th>
                                    <th>Student Name</th>
                                    <th>Class</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="studentTableBody">
                                <%
                                    try {
                                        String sql = "SELECT id, roll_no, full_name, class FROM users WHERE role='student' AND is_active=1 ORDER BY class, roll_no";
                                        pst = conn.prepareStatement(sql);
                                        rs = pst.executeQuery();
                                        
                                        while (rs.next()) {
                                            int studentId = rs.getInt("id");
                                            String rollNo = rs.getString("roll_no");
                                            String fullName = rs.getString("full_name");
                                            String studentClass = rs.getString("class");
                                            
                                            // Check today's status
                                            String status = "";
                                            String checkSql = "SELECT status FROM attendance WHERE student_id=? AND attendance_date=CURDATE()";
                                            PreparedStatement checkPst = conn.prepareStatement(checkSql);
                                            checkPst.setInt(1, studentId);
                                            ResultSet checkRs = checkPst.executeQuery();
                                            if (checkRs.next()) {
                                                status = checkRs.getString("status");
                                            }
                                            checkRs.close();
                                            checkPst.close();
                                %>
                                <tr data-student-id="<%= studentId %>" data-status="<%= status %>" class="student-row">
                                    <td><%= rollNo != null ? rollNo : "N/A" %></td>
                                    <td><%= fullName %></td>
                                    <td><%= studentClass != null ? studentClass : "N/A" %></td>
                                    <td class="status-cell-<%= studentId %>">
                                        <% if ("present".equals(status)) { %>
                                            <span class="attendance-badge badge-present">Present</span>
                                        <% } else if ("absent".equals(status)) { %>
                                            <span class="attendance-badge badge-absent">Absent</span>
                                        <% } else { %>
                                            <span class="text-muted">Not Marked</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <button class="btn btn-present btn-sm" type="button" onclick="markStatusSimple(<%= studentId %>, 'present')">
                                            <i class="fas fa-check"></i> Present
                                        </button>
                                        <button class="btn btn-absent btn-sm" type="button" onclick="markStatusSimple(<%= studentId %>, 'absent')">
                                            <i class="fas fa-times"></i> Absent
                                        </button>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- View Attendance Section -->
        <div id="view-attendance" class="page-section">
            <div class="header-card">
                <h2>View Attendance Records</h2>
                <p class="text-muted mb-0">View attendance history</p>
            </div>

            <div class="card">
                <div class="card-header">
                    <div class="row">
                        <div class="col-md-3">
                            <label>Start Date:</label>
                            <input type="date" class="form-control" id="viewStartDate">
                        </div>
                        <div class="col-md-3">
                            <label>End Date:</label>
                            <input type="date" class="form-control" id="viewEndDate" value="<%= today %>">
                        </div>
                        <div class="col-md-3">
                            <label>Class:</label>
                            <select class="form-select" id="viewClassFilter">
                                <option value="">All Classes</option>
                                <option value="10A">10A</option>
                                <option value="10-A">10-A</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label>&nbsp;</label>
                            <button class="btn btn-primary w-100" onclick="viewAttendanceRecords()">
                                <i class="fas fa-search"></i> Search
                            </button>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div id="viewAttendanceResults">
                        <p class="text-center text-muted">Select dates and click Search to view records</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Reports Section -->
        <div id="reports" class="page-section">
            <div class="header-card">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <h2>Attendance Reports</h2>
                        <p class="text-muted mb-0">Generate and export reports</p>
                    </div>
                    <div class="col-md-6 text-end">
                        <button class="btn btn-success" onclick="exportToExcel()">
                            <i class="fas fa-file-excel"></i> Export to Excel
                        </button>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h5>Monthly Attendance Summary</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label>Month:</label>
                            <select class="form-select" id="reportMonth">
                                <option value="1">January</option>
                                <option value="2">February</option>
                                <option value="3">March</option>
                                <option value="4">April</option>
                                <option value="5">May</option>
                                <option value="6">June</option>
                                <option value="7">July</option>
                                <option value="8">August</option>
                                <option value="9">September</option>
                                <option value="10">October</option>
                                <option value="11">November</option>
                                <option value="12" selected>December</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label>Year:</label>
                            <select class="form-select" id="reportYear">
                                <option value="2024">2024</option>
                                <option value="2025" selected>2025</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label>&nbsp;</label>
                            <button class="btn btn-primary w-100" onclick="generateReport()">
                                <i class="fas fa-chart-bar"></i> Generate Report
                            </button>
                        </div>
                    </div>
                    <div id="reportResults">
                        <p class="text-center text-muted">Select month and year, then click Generate Report</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Students Section -->
        <div id="students" class="page-section">
            <div class="header-card">
                <h2>Student List</h2>
                <p class="text-muted mb-0">View all students and their attendance summary</p>
            </div>

            <div class="card">
                <div class="card-header">
                    <input type="text" class="form-control" id="searchStudent" 
                           placeholder="Search by name or roll number..." onkeyup="searchStudents()">
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Roll No</th>
                                    <th>Name</th>
                                    <th>Class</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Monthly %</th>
                                </tr>
                            </thead>
                            <tbody id="studentListBody">
                                <%
                                    try {
                                        String sql = "SELECT u.id, u.roll_no, u.full_name, u.class, u.email, u.phone, " +
                                                   "COUNT(CASE WHEN a.status='present' AND MONTH(a.attendance_date)=MONTH(CURDATE()) THEN 1 END) as present_days, " +
                                                   "COUNT(CASE WHEN MONTH(a.attendance_date)=MONTH(CURDATE()) THEN 1 END) as total_days " +
                                                   "FROM users u " +
                                                   "LEFT JOIN attendance a ON u.id=a.student_id " +
                                                   "WHERE u.role='student' AND u.is_active=1 " +
                                                   "GROUP BY u.id ORDER BY u.class, u.roll_no";
                                        pst = conn.prepareStatement(sql);
                                        rs = pst.executeQuery();
                                        
                                        while (rs.next()) {
                                            int presentDays = rs.getInt("present_days");
                                            int totalDays = rs.getInt("total_days");
                                            double percentage = totalDays > 0 ? (double) presentDays / totalDays * 100 : 0;
                                %>
                                <tr>
                                    <td><%= rs.getString("roll_no") != null ? rs.getString("roll_no") : "N/A" %></td>
                                    <td><%= rs.getString("full_name") %></td>
                                    <td><%= rs.getString("class") != null ? rs.getString("class") : "N/A" %></td>
                                    <td><%= rs.getString("email") %></td>
                                    <td><%= rs.getString("phone") != null ? rs.getString("phone") : "N/A" %></td>
                                    <td>
                                        <% 
                                            String badgeClass = percentage >= 75 ? "bg-success" : percentage >= 50 ? "bg-warning" : "bg-danger";
                                        %>
                                        <span class="badge <%= badgeClass %>"><%= String.format("%.1f", percentage) %>%</span>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    } finally {
                                        if (rs != null) rs.close();
                                        if (pst != null) pst.close();
                                        if (conn != null) conn.close();
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // SIMPLIFIED Mark attendance function - GUARANTEED TO WORK
        function markStatusSimple(studentId, status) {
            try {
                console.log('Simple mark:', studentId, status);
                
                // Find status cell by unique class
                const statusCell = document.querySelector('.status-cell-' + studentId);
                
                if (!statusCell) {
                    alert('Error: Could not find status cell for student ' + studentId);
                    return;
                }
                
                // Update display
                if (status === 'present') {
                    statusCell.innerHTML = '<span class="attendance-badge badge-present">Present</span>';
                } else {
                    statusCell.innerHTML = '<span class="attendance-badge badge-absent">Absent</span>';
                }
                
                // Store change
                attendanceChanges[studentId] = status;
                console.log('Stored:', attendanceChanges);
                
                // Show success
                Swal.fire({
                    toast: true,
                    position: 'top-end',
                    icon: 'success',
                    title: 'Marked ' + status,
                    showConfirmButton: false,
                    timer: 800
                });
                
            } catch (error) {
                console.error('Error in markStatusSimple:', error);
                alert('JavaScript Error: ' + error.message);
            }
        }
        
        // Page Navigation
        function showPage(pageId) {
            document.querySelectorAll('.page-section').forEach(section => {
                section.classList.remove('active');
            });
            document.getElementById(pageId).classList.add('active');
            
            document.querySelectorAll('.nav-link').forEach(link => {
                link.classList.remove('active');
            });
            event.target.classList.add('active');
            
            if (pageId === 'dashboard') {
                loadDashboardChart();
            }
        }
        
        // Mark attendance status
        let attendanceChanges = {};
        
        function markStatus(studentId, status) {
            console.log('=== markStatus called ===');
            console.log('Student ID:', studentId);
            console.log('Student ID type:', typeof studentId);
            console.log('Status:', status);
            
            // Try to find all rows with data-student-id
            const allRows = document.querySelectorAll('tr[data-student-id]');
            console.log('Total rows with data-student-id:', allRows.length);
            
            if (allRows.length > 0) {
                console.log('First row data-student-id:', allRows[0].getAttribute('data-student-id'));
                
                // Log all student IDs
                allRows.forEach((row, index) => {
                    console.log(`Row ${index}: data-student-id = "${row.getAttribute('data-student-id')}"`);
                });
            }
            
            // Try different selectors
            const row1 = document.querySelector(`tr[data-student-id="${studentId}"]`);
            const row2 = document.querySelector(`tr.student-row[data-student-id="${studentId}"]`);
            const row3 = document.querySelector(`#studentTableBody tr[data-student-id="${studentId}"]`);
            
            console.log('Selector 1 result:', row1);
            console.log('Selector 2 result:', row2);
            console.log('Selector 3 result:', row3);
            
            const row = row3 || row2 || row1;
            
            if (!row) {
                console.error('❌ Row not found for student ID:', studentId);
                alert('Error: Could not find student row! Check console for details.');
                return;
            }
            
            console.log('✅ Found row:', row);
            
            const statusCell = row.querySelector('.status-cell');
            console.log('Found status cell:', statusCell);
            
            if (!statusCell) {
                console.error('Status cell not found!');
                alert('Error: Could not find status cell!');
                return;
            }
            
            row.setAttribute('data-status', status);
            
            if (status === 'present') {
                statusCell.innerHTML = '<span class="attendance-badge badge-present">Present</span>';
            } else {
                statusCell.innerHTML = '<span class="attendance-badge badge-absent">Absent</span>';
            }
            
            attendanceChanges[studentId] = status;
            console.log('✅ Current attendance changes:', attendanceChanges);
            
            Swal.fire({
                toast: true,
                position: 'top-end',
                icon: 'success',
                title: `Marked ${status}`,
                showConfirmButton: false,
                timer: 1000
            });
        }
        
        // Mark all present
        function markAllPresent() {
            Swal.fire({
                title: 'Mark All Present?',
                text: 'This will mark all students as present',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, mark all'
            }).then((result) => {
                if (result.isConfirmed) {
                    document.querySelectorAll('#studentTableBody tr').forEach(row => {
                        const studentId = row.getAttribute('data-student-id');
                        markStatus(studentId, 'present');
                    });
                }
            });
        }
        
        // Save all attendance
    // Save all attendance
function saveAllAttendance() {
    const date = document.getElementById('attendanceDate').value;
    
    // FIX: Get teacherId properly from JSP
    const teacherId = <%= teacherId != null ? teacherId : "0" %>;
    
    if (teacherId === 0) {
        Swal.fire('Error', 'Teacher ID not found. Please log in again.', 'error');
        return;
    }
    
    if (Object.keys(attendanceChanges).length === 0) {
        Swal.fire('No Changes', 'Please mark attendance for students', 'info');
        return;
    }
    
    console.log('=== SAVING ATTENDANCE ===');
    console.log('Date:', date);
    console.log('Teacher ID:', teacherId);
    console.log('Attendance Changes:', attendanceChanges);
    console.log('JSON:', JSON.stringify(attendanceChanges));
    
    document.getElementById('loading').style.display = 'flex';
    
    $.ajax({
        url: 'AttendanceServlet',
        method: 'POST',
        data: {
            action: 'saveAttendance',
            date: date,
            teacherId: teacherId,  // Now guaranteed to be a number
            attendance: JSON.stringify(attendanceChanges)
        },
        success: function(response) {
            console.log('Server Response:', response);
            document.getElementById('loading').style.display = 'none';
            
            if (response.success) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: response.message || 'Attendance saved successfully',
                    timer: 2000
                }).then(() => {
                    attendanceChanges = {};
                    window.location.reload();
                });
            } else {
                Swal.fire('Error', response.message || 'Failed to save', 'error');
            }
        },
        error: function(xhr, status, error) {
            console.error('AJAX Error:', status, error);
            console.error('Response:', xhr.responseText);
            document.getElementById('loading').style.display = 'none';
            Swal.fire('Error', 'Failed to save attendance: ' + error, 'error');
        }
    });
}
        
        // Load attendance for selected date
        function loadAttendanceForDate() {
            const date = document.getElementById('attendanceDate').value;
            const classFilter = document.getElementById('classFilter').value;
            
            document.getElementById('selectedDateDisplay').textContent = date;
            window.location.reload();
        }
        
        // View attendance records
        function viewAttendanceRecords() {
            const startDate = document.getElementById('viewStartDate').value;
            const endDate = document.getElementById('viewEndDate').value;
            const classFilter = document.getElementById('viewClassFilter').value;
            
            if (!startDate || !endDate) {
                Swal.fire('Error', 'Please select start and end dates', 'warning');
                return;
            }
            
            document.getElementById('loading').style.display = 'flex';
            
            $.ajax({
                url: 'AttendanceServlet',
                method: 'GET',
                data: {
                    action: 'viewAttendance',
                    startDate: startDate,
                    endDate: endDate,
                    class: classFilter
                },
                success: function(response) {
                    document.getElementById('loading').style.display = 'none';
                    
                    if (response.success && response.records) {
                        let html = '<div class="table-responsive"><table class="table table-bordered">';
                        html += '<thead><tr><th>Date</th><th>Roll No</th><th>Name</th><th>Class</th><th>Status</th></tr></thead>';
                        html += '<tbody>';
                        
                        response.records.forEach(record => {
                            const badgeClass = record.status === 'present' ? 'badge-present' : 'badge-absent';
                            html += `<tr>
                                <td>${record.date}</td>
                                <td>${record.rollNo}</td>
                                <td>${record.fullName}</td>
                                <td>${record.className}</td>
                                <td><span class="attendance-badge ${badgeClass}">${record.status}</span></td>
                            </tr>`;
                        });
                        
                        html += '</tbody></table></div>';
                        document.getElementById('viewAttendanceResults').innerHTML = html;
                    } else {
                        document.getElementById('viewAttendanceResults').innerHTML = '<p class="text-center text-muted">No records found</p>';
                    }
                },
                error: function() {
                    document.getElementById('loading').style.display = 'none';
                    Swal.fire('Error', 'Failed to load records', 'error');
                }
            });
        }
        
        // Generate monthly report
        function generateReport() {
            const month = document.getElementById('reportMonth').value;
            const year = document.getElementById('reportYear').value;
            
            document.getElementById('loading').style.display = 'flex';
            
            $.ajax({
                url: 'AttendanceServlet',
                method: 'GET',
                data: {
                    action: 'generateReport',
                    month: month,
                    year: year
                },
                success: function(response) {
                    document.getElementById('loading').style.display = 'none';
                    
                    if (response.success && response.report) {
                        let html = '<div class="table-responsive"><table class="table table-bordered">';
                        html += '<thead><tr><th>Roll No</th><th>Name</th><th>Class</th><th>Present Days</th><th>Absent Days</th><th>Total Days</th><th>Percentage</th></tr></thead>';
                        html += '<tbody>';
                        
                        response.report.forEach(student => {
                            const percentage = parseFloat(student.percentage);
                            const badgeClass = percentage >= 75 ? 'bg-success' : percentage >= 50 ? 'bg-warning' : 'bg-danger';
                            
                            html += `<tr>
                                <td>${student.rollNo}</td>
                                <td>${student.fullName}</td>
                                <td>${student.className}</td>
                                <td>${student.presentDays}</td>
                                <td>${student.absentDays}</td>
                                <td>${student.totalDays}</td>
                                <td><span class="badge ${badgeClass}">${student.percentage}%</span></td>
                            </tr>`;
                        });
                        
                        html += '</tbody></table></div>';
                        document.getElementById('reportResults').innerHTML = html;
                    } else {
                        document.getElementById('reportResults').innerHTML = '<p class="text-center text-muted">No data found</p>';
                    }
                },
                error: function() {
                    document.getElementById('loading').style.display = 'none';
                    Swal.fire('Error', 'Failed to generate report', 'error');
                }
            });
        }
        
        // Search students
        function searchStudents() {
            const searchTerm = document.getElementById('searchStudent').value.toLowerCase();
            const rows = document.querySelectorAll('#studentListBody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        }
        
        // Export to Excel (CSV format)
        function exportToExcel() {
            const month = document.getElementById('reportMonth').value;
            const year = document.getElementById('reportYear').value;
            
            $.ajax({
                url: 'AttendanceServlet',
                method: 'GET',
                data: {
                    action: 'generateReport',
                    month: month,
                    year: year
                },
                success: function(response) {
                    if (response.success && response.report) {
                        let csv = 'Roll No,Name,Class,Present Days,Absent Days,Total Days,Percentage\n';
                        
                        response.report.forEach(student => {
                            csv += `${student.rollNo},${student.fullName},${student.className},`;
                            csv += `${student.presentDays},${student.absentDays},${student.totalDays},${student.percentage}%\n`;
                        });
                        
                        const blob = new Blob([csv], { type: 'text/csv' });
                        const url = window.URL.createObjectURL(blob);
                        const a = document.createElement('a');
                        a.href = url;
                        a.download = `attendance_report_${year}_${month}.csv`;
                        document.body.appendChild(a);
                        a.click();
                        document.body.removeChild(a);
                        window.URL.revokeObjectURL(url);
                        
                        Swal.fire('Success', 'Report exported successfully', 'success');
                    }
                },
                error: function() {
                    Swal.fire('Error', 'Failed to export report', 'error');
                }
            });
        }
        
        // Load dashboard chart
        function loadDashboardChart() {
            $.ajax({
                url: 'AttendanceServlet',
                method: 'GET',
                data: { action: 'getChartData' },
                success: function(response) {
                    if (response.success && response.chartData) {
                        const ctx = document.getElementById('attendanceChart');
                        
                        if (window.attendanceChartInstance) {
                            window.attendanceChartInstance.destroy();
                        }
                        
                        window.attendanceChartInstance = new Chart(ctx, {
                            type: 'line',
                            data: {
                                labels: response.chartData.labels,
                                datasets: [{
                                    label: 'Present',
                                    data: response.chartData.present,
                                    borderColor: '#06d6a0',
                                    backgroundColor: 'rgba(6, 214, 160, 0.1)',
                                    tension: 0.4
                                }, {
                                    label: 'Absent',
                                    data: response.chartData.absent,
                                    borderColor: '#ef476f',
                                    backgroundColor: 'rgba(239, 71, 111, 0.1)',
                                    tension: 0.4
                                }]
                            },
                            options: {
                                responsive: true,
                                plugins: {
                                    legend: { position: 'top' }
                                },
                                scales: {
                                    y: { beginAtZero: true }
                                }
                            }
                        });
                    }
                }
            });
        }
        
        // Load chart on page load
        $(document).ready(function() {
            console.log('=== PAGE LOADED ===');
            console.log('jQuery loaded:', typeof jQuery !== 'undefined');
            console.log('SweetAlert loaded:', typeof Swal !== 'undefined');
            console.log('Chart.js loaded:', typeof Chart !== 'undefined');
            
            loadDashboardChart();
            
            // Setup attendance button click handlers
           // setupAttendanceButtons();
            
            // Test button click
            console.log('Testing button clicks...');
            const testButton = document.querySelector('.btn-present');
            if (testButton) {
                console.log('✅ Present button found');
            } else {
                console.error('❌ Present button NOT found');
            }
        });
        
        // Setup attendance button event listeners
        function setupAttendanceButtons() {
            console.log('=== Setting up attendance buttons ===');
            
            // Check which section is active
            const activeSection = document.querySelector('.page-section.active');
            console.log('Active section:', activeSection ? activeSection.id : 'none');
            
            // Check if attendance table exists
            const attendanceTable = document.getElementById('attendanceTable');
            const studentTableBody = document.getElementById('studentTableBody');
            console.log('Attendance table exists:', !!attendanceTable);
            console.log('Student table body exists:', !!studentTableBody);
            
            if (studentTableBody) {
                const rows = studentTableBody.querySelectorAll('tr[data-student-id]');
                console.log('Number of student rows:', rows.length);
            }
            
            // Use event delegation for dynamically loaded content
            /*$(document).on('click', '.btn-present, .btn-absent', function(e) {
                e.preventDefault();
                
                const button = $(this);
                const studentId = button.attr('data-student-id');
                const action = button.attr('data-action');
                
                console.log('Button clicked:', {
                    studentId: studentId,
                    action: action,
                    button: button
                });
                
                if (!studentId || !action) {
                    console.error('Missing data attributes!');
                    alert('Error: Missing student ID or action!');
                    return;
                }
                
                markStatus(studentId, action);
            });*/
            
            console.log('✅ Attendance buttons setup complete');
        }
        
        // Add global error handler
        window.onerror = function(msg, url, lineNo, columnNo, error) {
            console.error('JavaScript Error:', {
                message: msg,
                url: url,
                lineNo: lineNo,
                columnNo: columnNo,
                error: error
            });
            return false;
        };
    </script>
</body>
</html>