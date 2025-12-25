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
    
    <link rel="stylesheet" href="css/teacher.css">
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
               <a class="nav-link text-danger" href="#" onclick="confirmLogout()" style="color: white !important;">
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
                            <select class="form-select" id="classFilter" onchange="filterStudentsByClass()">
                                <option value="">All Classes</option>
                                <%
                                    try {
                                        String classSQL = "SELECT DISTINCT class FROM users WHERE role='student' AND is_active=1 AND class IS NOT NULL ORDER BY class";
                                        pst = conn.prepareStatement(classSQL);
                                        rs = pst.executeQuery();
                                        while (rs.next()) {
                                            String className = rs.getString("class");
                                            if (className != null && !className.trim().isEmpty()) {
                                %>
                                <option value="<%= className %>"><%= className %></option>
                                <%
                                            }
                                        }
                                        rs.close();
                                        pst.close();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
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
                                <tr data-student-id="<%= studentId %>" data-class="<%= studentClass != null ? studentClass : "" %>" class="student-row">
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
<!-- View Attendance Section - ENHANCED -->
<div id="view-attendance" class="page-section">
    <div class="header-card">
        <div class="row align-items-center">
            <div class="col-md-6">
                <h2><i class="fas fa-list-alt"></i> View Attendance Records</h2>
                <p class="text-muted mb-0">View and export attendance history</p>
            </div>
            <div class="col-md-6 text-end">
                <button class="btn btn-success" id="exportViewBtn" onclick="exportViewedAttendance()" style="display: none;">
                    <i class="fas fa-file-excel"></i> Export to Excel
                </button>
            </div>
        </div>
    </div>

    <div class="card mb-4">
        <div class="card-header">
            <ul class="nav nav-tabs card-header-tabs" id="viewTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="range-tab" data-bs-toggle="tab" 
                            data-bs-target="#range-view" type="button" role="tab">
                        <i class="fas fa-calendar-week"></i> Date Range
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="single-tab" data-bs-toggle="tab" 
                            data-bs-target="#single-view" type="button" role="tab">
                        <i class="fas fa-calendar-day"></i> Specific Date
                    </button>
                </li>
            </ul>
        </div>
        <div class="card-body">
            <div class="tab-content" id="viewTabsContent">
                
                <!-- Date Range Tab -->
                <div class="tab-pane fade show active" id="range-view" role="tabpanel">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label"><i class="fas fa-calendar-alt text-primary"></i> Start Date</label>
                            <input type="date" class="form-control" id="viewStartDate">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label"><i class="fas fa-calendar-alt text-danger"></i> End Date</label>
                            <input type="date" class="form-control" id="viewEndDate" value="<%= today %>">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label"><i class="fas fa-filter"></i> Class Filter</label>
                            <select class="form-select" id="viewClassFilter">
                                <option value="">All Classes</option>
                                <%
                                    try {
                                        conn = DatabaseConnection.getConnection();
                                        String classSQL = "SELECT DISTINCT class FROM users WHERE role='student' AND is_active=1 AND class IS NOT NULL AND class != '' ORDER BY class";
                                        pst = conn.prepareStatement(classSQL);
                                        rs = pst.executeQuery();
                                        while (rs.next()) {
                                            String className = rs.getString("class");
                                %>
                                <option value="<%= className %>"><%= className %></option>
                                <%
                                        }
                                        rs.close();
                                        pst.close();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <button class="btn btn-primary w-100" onclick="viewAttendanceByRange()">
                                <i class="fas fa-search"></i> Search Records
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Single Date Tab -->
                <div class="tab-pane fade" id="single-view" role="tabpanel">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label"><i class="fas fa-calendar-check text-success"></i> Select Date</label>
                            <input type="date" class="form-control" id="viewSingleDate" value="<%= today %>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label"><i class="fas fa-filter"></i> Class Filter</label>
                            <select class="form-select" id="viewSingleClassFilter">
                                <option value="">All Classes</option>
                                <%
                                    try {
                                        String classSQL2 = "SELECT DISTINCT class FROM users WHERE role='student' AND is_active=1 AND class IS NOT NULL AND class != '' ORDER BY class";
                                        pst = conn.prepareStatement(classSQL2);
                                        rs = pst.executeQuery();
                                        while (rs.next()) {
                                            String className = rs.getString("class");
                                %>
                                <option value="<%= className %>"><%= className %></option>
                                <%
                                        }
                                        rs.close();
                                        pst.close();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                %>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <button class="btn btn-success w-100" onclick="viewAttendanceByDate()">
                                <i class="fas fa-eye"></i> View Attendance
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Results Section -->
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="fas fa-table"></i> Attendance Records</h5>
            <div id="recordStats" class="text-muted"></div>
        </div>
        <div class="card-body">
            <div id="viewAttendanceResults">
                <div class="text-center py-5">
                    <i class="fas fa-search fa-3x text-muted mb-3"></i>
                    <p class="text-muted">Select date range or specific date and click Search to view records</p>
                </div>
            </div>
        </div>
    </div>
</div>

        <!-- Reports Section -->
<!-- Reports Section - ENHANCED -->
<div id="reports" class="page-section">
    <div class="header-card">
        <div class="row align-items-center">
            <div class="col-md-6">
                <h2><i class="fas fa-chart-bar"></i> Attendance Reports</h2>
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
            <h5><i class="fas fa-filter"></i> Report Type</h5>
        </div>
        <div class="card-body">
            <!-- Report Type Selection -->
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="btn-group w-100" role="group">
                        <input type="radio" class="btn-check" name="reportType" id="monthlyReport" value="monthly" checked onchange="toggleReportType()">
                        <label class="btn btn-outline-primary" for="monthlyReport">
                            <i class="fas fa-calendar-alt"></i> Monthly Report
                        </label>
                        
                        <input type="radio" class="btn-check" name="reportType" id="yearlyReport" value="yearly" onchange="toggleReportType()">
                        <label class="btn btn-outline-success" for="yearlyReport">
                            <i class="fas fa-calendar"></i> Yearly Report
                        </label>
                    </div>
                </div>
            </div>

            <!-- Monthly Report Section -->
            <div id="monthlyReportSection">
                <h6 class="mb-3"><i class="fas fa-calendar-month"></i> Monthly Attendance Summary</h6>
                <div class="row mb-3">
                    <div class="col-md-3">
                        <label class="form-label">Month:</label>
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
                    <div class="col-md-3">
                        <label class="form-label">Year:</label>
                        <select class="form-select" id="reportYear">
                            <%
                                int currentYear = Calendar.getInstance().get(Calendar.YEAR);
                                for (int i = currentYear; i >= currentYear - 5; i--) {
                            %>
                            <option value="<%= i %>" <%= i == currentYear ? "selected" : "" %>><%= i %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Class:</label>
                        <select class="form-select" id="reportClassFilter">
                            <option value="">All Classes</option>
                            <%
                                try {
                                    conn = DatabaseConnection.getConnection();
                                    String classSQL = "SELECT DISTINCT class FROM users WHERE role='student' AND is_active=1 AND class IS NOT NULL ORDER BY class";
                                    pst = conn.prepareStatement(classSQL);
                                    rs = pst.executeQuery();
                                    while (rs.next()) {
                                        String className = rs.getString("class");
                                        if (className != null && !className.trim().isEmpty()) {
                            %>
                            <option value="<%= className %>"><%= className %></option>
                            <%
                                        }
                                    }
                                    rs.close();
                                    pst.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">&nbsp;</label>
                        <button class="btn btn-primary w-100" onclick="generateReport()">
                            <i class="fas fa-chart-bar"></i> Generate Report
                        </button>
                    </div>
                </div>
            </div>

            <!-- Yearly Report Section -->
            <div id="yearlyReportSection" style="display: none;">
                <h6 class="mb-3"><i class="fas fa-calendar-year"></i> Yearly Attendance Summary</h6>
                <div class="row mb-3">
                    <div class="col-md-4">
                        <label class="form-label">Year:</label>
                        <select class="form-select" id="reportYearYearly">
                            <%
                                int currentYear2 = Calendar.getInstance().get(Calendar.YEAR);
                                for (int i = currentYear2; i >= currentYear2 - 5; i--) {
                            %>
                            <option value="<%= i %>" <%= i == currentYear2 ? "selected" : "" %>><%= i %></option>
                            <%
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Class:</label>
                        <select class="form-select" id="reportClassFilterYearly">
                            <option value="">All Classes</option>
                            <%
                                try {
                                    String classSQL2 = "SELECT DISTINCT class FROM users WHERE role='student' AND is_active=1 AND class IS NOT NULL ORDER BY class";
                                    pst = conn.prepareStatement(classSQL2);
                                    rs = pst.executeQuery();
                                    while (rs.next()) {
                                        String className = rs.getString("class");
                                        if (className != null && !className.trim().isEmpty()) {
                            %>
                            <option value="<%= className %>"><%= className %></option>
                            <%
                                        }
                                    }
                                    rs.close();
                                    pst.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">&nbsp;</label>
                        <button class="btn btn-success w-100" onclick="generateReport()">
                            <i class="fas fa-chart-line"></i> Generate Yearly Report
                        </button>
                    </div>
                </div>
            </div>

            <!-- Report Results -->
            <div id="reportResults" class="mt-4">
                <p class="text-center text-muted">Select filters and click Generate Report</p>
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
        <!-- Footer Credit -->
        <div class="credit-badge">
    <i class="fas fa-user-graduate"></i>
    <span>Created by <strong>Shravani & Sanika</strong></span>
</div>

    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>


<script>
    // Values coming from JSP / session - FIXED
    const TEACHER_ID = '<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : 0 %>';
    console.log('🔐 Teacher ID from session:', TEACHER_ID);
</script>


<script src="js/teacher.js"></script>

</body>
</html>