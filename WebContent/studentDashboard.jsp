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
    
 <link rel="stylesheet" href="css/student.css">
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
                
                
             <button type="button" class="btn btn-logout" onclick="confirmLogout()" >
    <i class="fas fa-sign-out-alt"></i> Logout
</button>

                
                
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
        <!-- Footer Credit -->
<!-- Professional Footer Credit -->
<div class="credit-badge">
    <i class="fas fa-user-graduate"></i>
    <span>Created by <strong>Shravani Sanika</strong></span>
</div>

    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Values coming from server (JSP)
    const STUDENT_ID   = <%= studentId %>;
    const TOTAL_DAYS   = <%= totalDays %>;
    const PRESENT_DAYS = <%= presentDays %>;
    const ABSENT_DAYS  = <%= absentDays %>;
</script>

<script src="js/student.js"></script>

</body>
</html>