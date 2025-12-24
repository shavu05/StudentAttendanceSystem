<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="com.attendance.util.DatabaseConnection" %>
<%
    // ============================================
    // SESSION VALIDATION - ONLY FOR STUDENT
    // ============================================
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!"student".equals(role)) {
        response.sendRedirect("login.jsp?error=Access denied. Students only.");
        return;
    }
    
    // Get logged-in student's ID
    Integer studentId = (Integer) session.getAttribute("userId");
    String studentName = (String) session.getAttribute("fullName");
    
    if (studentId == null) {
        response.sendRedirect("login.jsp?error=Session expired");
        return;
    }
    
    // ============================================
    // FETCH STUDENT'S PERSONAL DATA ONLY
    // ============================================
    String rollNo = "N/A";
    String className = "N/A";
    String email = "N/A";
    String phone = "N/A";
    String department = "N/A";
    String username = "N/A";
    
    int totalDays = 0;
    int presentDays = 0;
    int absentDays = 0;
    double attendancePercentage = 0.0;
    
    // Monthly stats
    int monthlyTotalDays = 0;
    int monthlyPresentDays = 0;
    int monthlyAbsentDays = 0;
    double monthlyPercentage = 0.0;
    
    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
    
    try {
        conn = DatabaseConnection.getConnection();
        
        // ============================================
        // GET STUDENT PERSONAL DETAILS
        // ============================================
        String sqlUser = "SELECT username, roll_no, class, email, phone, department, full_name " +
                        "FROM users WHERE id = ? AND role = 'student'";
        pst = conn.prepareStatement(sqlUser);
        pst.setInt(1, studentId);
        rs = pst.executeQuery();
        
        if (rs.next()) {
            username = rs.getString("username");
            rollNo = rs.getString("roll_no") != null ? rs.getString("roll_no") : "N/A";
            className = rs.getString("class") != null ? rs.getString("class") : "N/A";
            email = rs.getString("email") != null ? rs.getString("email") : "N/A";
            phone = rs.getString("phone") != null ? rs.getString("phone") : "N/A";
            department = rs.getString("department") != null ? rs.getString("department") : "N/A";
            studentName = rs.getString("full_name") != null ? rs.getString("full_name") : studentName;
        }
        rs.close();
        pst.close();
        
        // ============================================
        // GET OVERALL ATTENDANCE STATISTICS
        // ============================================
        String sqlStats = "SELECT " +
                         "COUNT(*) as total_days, " +
                         "SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) as present_days, " +
                         "SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) as absent_days " +
                         "FROM attendance WHERE student_id = ?";
        
        pst = conn.prepareStatement(sqlStats);
        pst.setInt(1, studentId);
        rs = pst.executeQuery();
        
        if (rs.next()) {
            totalDays = rs.getInt("total_days");
            presentDays = rs.getInt("present_days");
            absentDays = rs.getInt("absent_days");
            
            if (totalDays > 0) {
                attendancePercentage = ((double) presentDays / totalDays) * 100;
            }
        }
        rs.close();
        pst.close();
        
        // ============================================
        // GET MONTHLY ATTENDANCE STATISTICS
        // ============================================
        String sqlMonthly = "SELECT " +
                           "COUNT(*) as total_days, " +
                           "SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) as present_days, " +
                           "SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) as absent_days " +
                           "FROM attendance " +
                           "WHERE student_id = ? " +
                           "AND MONTH(attendance_date) = MONTH(CURDATE()) " +
                           "AND YEAR(attendance_date) = YEAR(CURDATE())";
        
        pst = conn.prepareStatement(sqlMonthly);
        pst.setInt(1, studentId);
        rs = pst.executeQuery();
        
        if (rs.next()) {
            monthlyTotalDays = rs.getInt("total_days");
            monthlyPresentDays = rs.getInt("present_days");
            monthlyAbsentDays = rs.getInt("absent_days");
            
            if (monthlyTotalDays > 0) {
                monthlyPercentage = ((double) monthlyPresentDays / monthlyTotalDays) * 100;
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('Database Error: " + e.getMessage() + "');</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pst != null) try { pst.close(); } catch (SQLException e) { }
        // Don't close connection yet - we need it for attendance records below
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Dashboard - <%= studentName %></title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <style>
        :root {
            --primary: #667eea;
            --secondary: #764ba2;
            --success: #06d6a0;
            --danger: #ef476f;
            --warning: #ffd166;
            --info: #4cc9f0;
            --dark: #2d3748;
        }
        
        body {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding-bottom: 50px;
        }
        
        /* Navbar */
        .navbar {
            background: white !important;
            box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            padding: 15px 0;
        }
        
        .navbar-brand {
            color: var(--primary) !important;
            font-weight: 700;
            font-size: 1.5rem;
        }
        
        .btn-logout {
            background: linear-gradient(135deg, var(--danger), #c0392b);
            color: white;
            border: none;
            padding: 8px 25px;
            border-radius: 25px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-logout:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 20px rgba(239, 71, 111, 0.4);
            color: white;
        }
        
        /* Container */
        .dashboard-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        /* Profile Card */
        .profile-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .profile-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: linear-gradient(90deg, var(--primary), var(--secondary));
        }
        
        .profile-header {
            display: flex;
            align-items: center;
            gap: 30px;
            margin-bottom: 30px;
        }
        
        .profile-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 48px;
            font-weight: 700;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        
        .profile-info h2 {
            color: var(--dark);
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .profile-meta {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }
        
        .meta-badge {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            color: var(--primary);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        
        .info-item {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            border-left: 4px solid var(--primary);
        }
        
        .info-label {
            font-size: 12px;
            text-transform: uppercase;
            color: #6c757d;
            font-weight: 600;
            margin-bottom: 8px;
        }
        
        .info-value {
            font-size: 18px;
            color: var(--dark);
            font-weight: 600;
        }
        
        /* Stats Cards */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
        }
        
        .stat-card.overall::before { background: var(--primary); }
        .stat-card.present::before { background: var(--success); }
        .stat-card.absent::before { background: var(--danger); }
        .stat-card.monthly::before { background: var(--warning); }
        
        .stat-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 20px;
        }
        
        .stat-card.overall .stat-icon {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.2), rgba(118, 75, 162, 0.2));
            color: var(--primary);
        }
        
        .stat-card.present .stat-icon {
            background: rgba(6, 214, 160, 0.2);
            color: var(--success);
        }
        
        .stat-card.absent .stat-icon {
            background: rgba(239, 71, 111, 0.2);
            color: var(--danger);
        }
        
        .stat-card.monthly .stat-icon {
            background: rgba(255, 209, 102, 0.2);
            color: var(--warning);
        }
        
        .stat-value {
            font-size: 36px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        
        .stat-label {
            color: #6c757d;
            font-size: 14px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .stat-sublabel {
            color: #adb5bd;
            font-size: 12px;
            margin-top: 5px;
        }
        
        /* Chart Card */
        .chart-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .chart-header {
            margin-bottom: 25px;
        }
        
        .chart-header h4 {
            color: var(--dark);
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        /* Attendance Table */
        .table-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }
        
        .table-header h4 {
            color: var(--dark);
            font-weight: 700;
            margin: 0;
        }
        
        .table {
            margin-bottom: 0;
        }
        
        .table thead th {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            color: var(--dark);
            font-weight: 700;
            border: none;
            padding: 15px;
            text-transform: uppercase;
            font-size: 12px;
        }
        
        .table tbody td {
            padding: 15px;
            vertical-align: middle;
            border-bottom: 1px solid #e9ecef;
        }
        
        .table tbody tr:last-child td {
            border-bottom: none;
        }
        
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
        
        .status-badge.present {
            background: rgba(6, 214, 160, 0.2);
            color: var(--success);
        }
        
        .status-badge.absent {
            background: rgba(239, 71, 111, 0.2);
            color: var(--danger);
        }
        
        .status-badge.late {
            background: rgba(255, 209, 102, 0.2);
            color: var(--warning);
        }
        
        .status-badge.excused {
            background: rgba(76, 201, 240, 0.2);
            color: var(--info);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #adb5bd;
        }
        
        .empty-state i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        /* Alert Box */
        .attendance-alert {
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 30px;
            border: none;
            font-weight: 600;
        }
        
        .attendance-alert i {
            margin-right: 10px;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .profile-header {
                flex-direction: column;
                text-align: center;
            }
            
            .stats-row {
                grid-template-columns: 1fr;
            }
            
            .table-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">
                <i class="fas fa-user-graduate"></i> Student Portal
            </a>
            <div class="ms-auto d-flex align-items-center gap-3">
                <span class="d-none d-sm-inline">Welcome, <strong><%= studentName %></strong></span>
                <form action="LoginServlet" method="post" style="margin: 0;">
                    <input type="hidden" name="action" value="logout">
                    <button type="submit" class="btn btn-logout">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </button>
                </form>
            </div>
        </div>
    </nav>

    <div class="dashboard-container">
        <!-- Profile Card -->
        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-avatar">
                    <%= studentName.substring(0, 1).toUpperCase() %>
                </div>
                <div class="profile-info">
                    <h2><%= studentName %></h2>
                    <div class="profile-meta">
                        <span class="meta-badge">
                            <i class="fas fa-id-card"></i> <%= rollNo %>
                        </span>
                        <span class="meta-badge">
                            <i class="fas fa-school"></i> <%= className %>
                        </span>
                        <span class="meta-badge">
                            <i class="fas fa-building"></i> <%= department %>
                        </span>
                    </div>
                </div>
            </div>
            
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">
                        <i class="fas fa-user"></i> Username
                    </div>
                    <div class="info-value"><%= username %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">
                        <i class="fas fa-envelope"></i> Email
                    </div>
                    <div class="info-value"><%= email %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">
                        <i class="fas fa-phone"></i> Phone
                    </div>
                    <div class="info-value"><%= phone %></div>
                </div>
                <div class="info-item">
                    <div class="info-label">
                        <i class="fas fa-id-badge"></i> Student ID
                    </div>
                    <div class="info-value">#<%= studentId %></div>
                </div>
            </div>
        </div>

        <!-- Attendance Alert -->
        <% if (totalDays > 0) { %>
            <% if (attendancePercentage >= 75) { %>
                <div class="alert attendance-alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <strong>Excellent!</strong> Your attendance is above 75%. Keep up the good work!
                </div>
            <% } else if (attendancePercentage >= 60) { %>
                <div class="alert attendance-alert alert-warning">
                    <i class="fas fa-exclamation-triangle"></i>
                    <strong>Warning!</strong> Your attendance is below 75%. Please improve your attendance.
                </div>
            <% } else { %>
                <div class="alert attendance-alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i>
                    <strong>Critical!</strong> Your attendance is critically low. Immediate action required!
                </div>
            <% } %>
        <% } %>

        <!-- Stats Cards -->
        <div class="stats-row">
            <div class="stat-card overall">
                <div class="stat-icon">
                    <i class="fas fa-calendar-alt"></i>
                </div>
                <div class="stat-value" style="color: var(--primary);"><%= totalDays %></div>
                <div class="stat-label">Total Days</div>
                <div class="stat-sublabel">Overall attendance tracked</div>
            </div>
            
            <div class="stat-card present">
                <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-value" style="color: var(--success);"><%= presentDays %></div>
                <div class="stat-label">Present Days</div>
                <div class="stat-sublabel"><%= String.format("%.1f", attendancePercentage) %>% of total</div>
            </div>
            
            <div class="stat-card absent">
                <div class="stat-icon">
                    <i class="fas fa-times-circle"></i>
                </div>
                <div class="stat-value" style="color: var(--danger);"><%= absentDays %></div>
                <div class="stat-label">Absent Days</div>
                <div class="stat-sublabel"><%= totalDays > 0 ? String.format("%.1f", ((double)absentDays/totalDays)*100) : "0.0" %>% of total</div>
            </div>
            
            <div class="stat-card monthly">
                <div class="stat-icon">
                    <i class="fas fa-calendar-week"></i>
                </div>
                <div class="stat-value" style="color: var(--warning);"><%= String.format("%.1f", monthlyPercentage) %>%</div>
                <div class="stat-label">This Month</div>
                <div class="stat-sublabel"><%= monthlyPresentDays %>/<%= monthlyTotalDays %> days present</div>
            </div>
        </div>

        <!-- Attendance Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <h4><i class="fas fa-chart-pie"></i> Attendance Overview</h4>
                <p class="text-muted mb-0">Visual representation of your attendance</p>
            </div>
            <div style="max-width: 400px; margin: 0 auto;">
                <canvas id="attendanceChart"></canvas>
            </div>
        </div>

        <!-- Recent Attendance Records -->
        <div class="table-card">
            <div class="table-header">
                <h4><i class="fas fa-list"></i> My Attendance Records</h4>
                <span class="badge bg-primary">Last 30 Records</span>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th><i class="fas fa-calendar"></i> Date</th>
                            <th><i class="fas fa-info-circle"></i> Status</th>
                            <th><i class="fas fa-clock"></i> Marked At</th>
                            <th><i class="fas fa-comment"></i> Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        boolean hasRecords = false;
                        try {
                            if (conn == null || conn.isClosed()) {
                                conn = DatabaseConnection.getConnection();
                            }
                            
                            String sqlRecords = "SELECT attendance_date, status, marked_at, remarks " +
                                              "FROM attendance " +
                                              "WHERE student_id = ? " +
                                              "ORDER BY attendance_date DESC " +
                                              "LIMIT 30";
                            pst = conn.prepareStatement(sqlRecords);
                            pst.setInt(1, studentId);
                            rs = pst.executeQuery();
                            
                            while (rs.next()) {
                                hasRecords = true;
                                String status = rs.getString("status");
                                Date date = rs.getDate("attendance_date");
                                Timestamp markedAt = rs.getTimestamp("marked_at");
                                String remarks = rs.getString("remarks");
                        %>
                        <tr>
                            <td><strong><%= date %></strong></td>
                            <td>
                                <span class="status-badge <%= status %>">
                                    <% if ("present".equals(status)) { %>
                                        <i class="fas fa-check"></i>
                                    <% } else if ("absent".equals(status)) { %>
                                        <i class="fas fa-times"></i>
                                    <% } else if ("late".equals(status)) { %>
                                        <i class="fas fa-clock"></i>
                                    <% } else { %>
                                        <i class="fas fa-info"></i>
                                    <% } %>
                                    <%= status.toUpperCase() %>
                                </span>
                            </td>
                            <td><%= markedAt != null ? markedAt : "Not specified" %></td>
                            <td><%= remarks != null && !remarks.isEmpty() ? remarks : "-" %></td>
                        </tr>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<tr><td colspan='4' class='text-center text-danger'>Error loading records: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) { }
                            if (pst != null) try { pst.close(); } catch (SQLException e) { }
                            if (conn != null) try { conn.close(); } catch (SQLException e) { }
                        }
                        
                        if (!hasRecords) {
                        %>
                        <tr>
                            <td colspan="4">
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <h5>No Attendance Records Found</h5>
                                    <p>Your attendance records will appear here once they are marked by your teacher.</p>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Attendance Pie Chart
        const ctx = document.getElementById('attendanceChart').getContext('2d');
        
        const presentDays = <%= presentDays %>;
        const absentDays = <%= absentDays %>;
        const totalDays = <%= totalDays %>;
        
        if (totalDays > 0) {
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Present', 'Absent'],
                    datasets: [{
                        data: [presentDays, absentDays],
                        backgroundColor: [
                            'rgba(6, 214, 160, 0.8)',
                            'rgba(239, 71, 111, 0.8)'
                        ],
                        borderColor: [
                            'rgba(6, 214, 160, 1)',
                            'rgba(239, 71, 111, 1)'
                        ],
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                font: {
                                    size: 14,
                                    weight: 600
                                },
                                padding: 20
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.parsed || 0;
                                    const percentage = ((value / totalDays) * 100).toFixed(1);
                                    return label + ': ' + value + ' days (' + percentage + '%)';
                                }
                            }
                        }
                    }
                }
            });
        } else {
            document.querySelector('.chart-card').innerHTML = 
                '<div class="empty-state">' +
                '<i class="fas fa-chart-pie"></i>' +
                '<h5>No Data Available</h5>' +
                '<p>Attendance chart will appear once your attendance is marked.</p>' +
                '</div>';
        }
        
        console.log('✅ Student Dashboard Loaded');
        console.log('Student ID:', <%= studentId %>);
        console.log('Total Days:', totalDays);
        console.log('Present Days:', presentDays);
        console.log('Absent Days:', absentDays);
    </script>
</body>
</html>